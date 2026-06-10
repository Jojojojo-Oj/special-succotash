import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class BleSosRelay {
  BleSosRelay._();
  static final BleSosRelay instance = BleSosRelay._();

  static const int manufacturerId = 0x1234;
  static const int payloadLength = 18;
  static const String _pendingKey = 'pending_sos_reports';

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Timer? _advertiseStopTimer;
  Timer? _scanRestartTimer;

  bool _started = false;
  bool _isAdvertising = false;
  bool _storageInitialized = false;

  final Set<String> _seen = <String>{};
  final Queue<String> _seenOrder = ListQueue<String>();

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final permissionsOk = await _ensurePermissions();
    if (!permissionsOk) {
      _started = false;
      return;
    }

    final bluetoothOk = await _ensureBluetoothOn();
    if (!bluetoothOk) {
      _started = false;
      return;
    }

    await _ensureStorageReady();

    _scanSub = FlutterBluePlus.scanResults.listen(_handleScanResults);
    await _startScan();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        _flushPending();
      }
    });

    if (await _isOnline()) {
      await _flushPending();
    }
  }

  Future<void> _ensureStorageReady() async {
    if (!_storageInitialized) {
      try {
        await Hive.initFlutter();
      } catch (_) {}
      _storageInitialized = true;
    }

    if (!Hive.isBoxOpen(_pendingKey)) {
      await Hive.openBox<String>(_pendingKey);
    }
  }

  Future<Box<String>> _getPendingBox() async {
    await _ensureStorageReady();
    return Hive.box<String>(_pendingKey);
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<bool> _ensureBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) return true;

    await FlutterBluePlus.turnOn();
    final updated = await FlutterBluePlus.adapterState.first;
    return updated == BluetoothAdapterState.on;
  }

  Future<void> _startScan() async {
    if (_isAdvertising) return;

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(minutes: 5));

      _scanRestartTimer?.cancel();
      _scanRestartTimer = Timer(const Duration(minutes: 5), () {
        if (_started && !_isAdvertising) {
          _startScan();
        }
      });
    } catch (_) {}
  }

  Future<void> stop() async {
    _started = false;

    await _scanSub?.cancel();
    await FlutterBluePlus.stopScan();
    await _connectivitySub?.cancel();

    _advertiseStopTimer?.cancel();
    _scanRestartTimer?.cancel();

    await _peripheral.stop();
  }

  Future<void> broadcastPayload(Uint8List payload) async {
    if (payload.length != payloadLength) return;

    final supported = await _peripheral.isSupported;
    if (!supported || _isAdvertising) return;

    _isAdvertising = true;
    await FlutterBluePlus.stopScan();

    final data = AdvertiseData(
      includeDeviceName: false,
      manufacturerId: manufacturerId,
      manufacturerData: payload,
    );

    try {
      await _peripheral.start(advertiseData: data);
    } catch (_) {
      _isAdvertising = false;
      return;
    }

    _advertiseStopTimer?.cancel();
    _advertiseStopTimer = Timer(const Duration(seconds: 8), () async {
      await _peripheral.stop();
      _isAdvertising = false;
      await _startScan();
    });
  }

  void _handleScanResults(List<ScanResult> results) {
    for (final result in results) {
      final manufacturerData = result.advertisementData.manufacturerData;

      for (final entry in manufacturerData.entries) {
        if (entry.key != manufacturerId) continue;

        final payload = Uint8List.fromList(entry.value);
        if (payload.length != payloadLength) continue;

        _handlePayload(payload);
      }
    }
  }

  Future<void> _handlePayload(Uint8List payload) async {
    final key = base64Encode(payload);
    if (_seen.contains(key)) return;

    _markSeen(key);

    final parsed = _parsePayload(payload);
    await _uploadIfOnline(payload);

    if (parsed.ttl <= 0) return;

    final rebroadcast = Uint8List.fromList(payload);
    rebroadcast[17] = (parsed.ttl - 1).clamp(0, 255);

    await broadcastPayload(rebroadcast);
  }

  Future<void> queuePendingPayload(Uint8List payload) async {
    await _storePending(payload);
  }

  Future<void> _uploadIfOnline(Uint8List payload) async {
    if (await _isOnline()) {
      await _uploadToFirestore(payload);
    } else {
      await _storePending(payload);
    }
  }

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<void> _uploadToFirestore(Uint8List payload) async {
    final parsed = _parsePayload(payload);
    final docId = '${_toHex(parsed.idHash)}_${parsed.timestampSeconds}';

    await FirebaseFirestore.instance
        .collection('sos_reports_emergency')
        .doc(docId)
        .set({
      'senderIdHash': _toHex(parsed.idHash),
      'timeServer': FieldValue.serverTimestamp(),
      'latitude': parsed.latitude,
      'longitude': parsed.longitude,
      'batteryLevel': parsed.battery == 255 ? null : parsed.battery,
      'ttl': parsed.ttl,
    }, SetOptions(merge: true));
  }

  Future<void> _storePending(Uint8List payload) async {
    final encoded = base64Encode(payload);
    final box = await _getPendingBox();
    if (!box.containsKey(encoded)) {
      await box.put(encoded, encoded);
    }
  }

  Future<void> _flushPending() async {
    final box = await _getPendingBox();
    if (box.isEmpty) return;

    final remaining = <String, String>{};
    for (final item in box.values) {
      try {
        final payload = base64Decode(item);
        await _uploadToFirestore(Uint8List.fromList(payload));
      } catch (_) {
        remaining[item] = item;
      }
    }

    await box.clear();
    if (remaining.isNotEmpty) {
      await box.putAll(remaining);
    }
  }

  SosPayload _parsePayload(Uint8List payload) {
    final data = ByteData.sublistView(payload);

    final battery = data.getUint8(0);
    final latMicros = data.getInt32(1, Endian.little);
    final lonMicros = data.getInt32(5, Endian.little);
    final timestamp = data.getUint32(9, Endian.little);
    final idHash = payload.sublist(13, 17);
    final ttl = data.getUint8(17);

    return SosPayload(
      battery: battery,
      latitude: latMicros / 1000000,
      longitude: lonMicros / 1000000,
      timestampSeconds: timestamp,
      idHash: Uint8List.fromList(idHash),
      ttl: ttl,
    );
  }

  void _markSeen(String key) {
    _seen.add(key);
    _seenOrder.add(key);

    if (_seenOrder.length > 200) {
      final oldest = _seenOrder.removeFirst();
      _seen.remove(oldest);
    }
  }

  String _toHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

class SosPayload {
  final int battery;
  final double latitude;
  final double longitude;
  final int timestampSeconds;
  final Uint8List idHash;
  final int ttl;

  const SosPayload({
    required this.battery,
    required this.latitude,
    required this.longitude,
    required this.timestampSeconds,
    required this.idHash,
    required this.ttl,
  });
}
