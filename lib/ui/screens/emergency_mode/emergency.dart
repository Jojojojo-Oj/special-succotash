import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'ble_sos_relay.dart';

class EmergencyOverlay extends StatefulWidget {
  final VoidCallback onSendSOS;

  const EmergencyOverlay({
    super.key,
    required this.onSendSOS,
  });

  @override
  State<EmergencyOverlay> createState() => _EmergencyOverlayState();
}

class _EmergencyOverlayState extends State<EmergencyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;
  bool _isCooldown = false;
  Timer? _vibrationTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    BleSosRelay.instance.start();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await HapticFeedback.heavyImpact();
        _stopHolding();

        _startCooldown();

        final isOnline = await _sendSosReport();

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              final title = isOnline ? 'SOS SENT' : 'SOS QUEUED';
              final content = isOnline
                  ? 'Your emergency alert has been sent successfully.'
                  : 'No internet connection. Your SOS will be sent automatically when online.';
              final icon = isOnline
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                  : const Icon(Icons.cloud_off, color: Colors.orange, size: 30);
              final buttonColor = isOnline ? Colors.green : Colors.orange;

              return AlertDialog(
                backgroundColor: Colors.white,
                title: Row(
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(title),
                  ],
                ),
                content: Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }

        widget.onSendSOS();
      }
    });
  }

  void _startHolding() async {
    if (_isCooldown) {
      return;
    }
    setState(() => _isHolding = true);

    await HapticFeedback.mediumImpact();
    _controller.forward(from: 0);

    _vibrationTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) async {
        await HapticFeedback.lightImpact();
      },
    );
  }

  void _stopHolding() {
    setState(() => _isHolding = false);
    _controller.stop();
    _controller.reset();

    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _isCooldown = true);
    _cooldownTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _isCooldown = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _vibrationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<bool> _sendSosReport() async {
    debugPrint('BLE SOS -> _sendSosReport start');
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    const ttl = 5;
    int? batteryLevel;
    double? latitude;
    double? longitude;

    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    try {
      batteryLevel = await Battery().batteryLevel;
    } catch (e) {
      debugPrint('SOS DEBUG -> battery error: $e');
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services disabled');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      debugPrint('SOS DEBUG -> location error: $e');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = _buildBlePayload(
      userId: userId,
      batteryLevel: batteryLevel,
      latitude: latitude, 
      longitude: longitude, 
      timestampSeconds: timestamp,
      ttl: ttl,
    );
    debugPrint('SOS BLE PAYLOAD (${payload.length} bytes): ${_toHex(payload)}');
    debugPrint('SOS BLE BYTES: ${payload.toList()}');
    debugPrint('BLE SOS -> will start relay and broadcast');
    await BleSosRelay.instance.start();
    await BleSosRelay.instance.broadcastPayload(payload);
    debugPrint('BLE SOS -> broadcast done');

    if (isOnline) {
      try {
        // Create deterministic doc ID to prevent duplicates
        final userIdHash = Uint8List.fromList(
            sha256.convert(utf8.encode(userId)).bytes.sublist(0, 4));
        final docId = '${_toHex(userIdHash)}_$timestamp';

        await FirebaseFirestore.instance
            .collection('sos_reports_emergency')
            .doc(docId)
            .set({
          'senderIdHash': _toHex(userIdHash),
          'timeServer': FieldValue.serverTimestamp(),
          'latitude': latitude,
          'longitude': longitude,
          'batteryLevel': batteryLevel,
          'ttl': ttl,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('SOS DEBUG -> firestore error: $e');
        await BleSosRelay.instance.queuePendingPayload(payload);
      }
    } else {
      await BleSosRelay.instance.queuePendingPayload(payload);
    }

    final batteryText = batteryLevel?.toString() ?? 'unknown';
    debugPrint(
      'SOS DEBUG -> userId=$userId, lat=$latitude, long=$longitude, battery=$batteryText, online=$isOnline',
    );

    return isOnline;
  }

  Uint8List _buildBlePayload({
    required String userId,
    required int? batteryLevel,
    required double? latitude,
    required double? longitude,
    required int timestampSeconds,
    int ttl = 5,
  }) {
    final data = ByteData(18);
    final battery = batteryLevel == null
        ? 255 
        : batteryLevel.clamp(0, 100) as int;
    final latMicros = ((latitude ?? 0) * 1000000).round();
    final lonMicros = ((longitude ?? 0) * 1000000).round();
    final idHash = sha256.convert(utf8.encode(userId)).bytes;
    final ttlValue = ttl.clamp(0, 255) as int;

    data.setUint8(0, battery);
    data.setInt32(1, latMicros, Endian.little);
    data.setInt32(5, lonMicros, Endian.little);
    data.setUint32(9, timestampSeconds, Endian.little);
    data.setUint8(13, idHash[0]);
    data.setUint8(14, idHash[1]);
    data.setUint8(15, idHash[2]);
    data.setUint8(16, idHash[3]);
    data.setUint8(17, ttlValue);

    return data.buffer.asUint8List();
  }

  String _toHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'EMERGENCY MODE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),

            GestureDetector(
              onLongPressStart: _isCooldown ? null : (_) => _startHolding(),
              onLongPressEnd: _isCooldown ? null : (_) => _stopHolding(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isHolding)
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _controller.value,
                            strokeWidth: 8,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.white),
                            backgroundColor:
                                Colors.white.withOpacity(0.2),
                          );
                        },
                      ),
                    ),

                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sos,
                          size: 70,
                          color: Colors.red,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'SEND SOS',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
            const Text(
              'Press and hold for 5 seconds to send SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (_isCooldown) ...[
              const SizedBox(height: 12),
              const Text(
                'Cooldown: 30 seconds',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

