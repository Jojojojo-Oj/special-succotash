import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Shows live rescuer locations by combining:
/// 1. Rescuer IDs from the Firestore `sos_reports/{reportId}` document.
/// 2. GPS coordinates from Realtime Database `rescuer_locations/{rescuerId}`.
/// 3. The user's live location (if permission is granted).
class TrackRescuerMap extends StatefulWidget {
  const TrackRescuerMap({super.key, required this.reportId});

  final String reportId;

  @override
  State<TrackRescuerMap> createState() => _TrackRescuerMapState();
}

class _TrackRescuerMapState extends State<TrackRescuerMap> {
  static const LatLng _defaultLatLng = LatLng(14.5995, 120.9842); // Manila

  late final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://agapay-capstone-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
  final Set<Marker> _rescuerMarkers = {};
  Set<String> _rescuerIds = {};
  LatLng? _userLocation;
  bool _hasLocationPermission = false;
  bool _hasMovedCamera = false;
  bool _loading = true;
  String? _statusMessage;
  BitmapDescriptor? _rescuerIcon;
  Set<Circle> _userCircles = {};

  GoogleMapController? _mapController;
  StreamSubscription<DatabaseEvent>? _rtdbSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _reportSub;
  StreamSubscription<Position>? _positionSub;
  String? _rtdbError;

  void _setStateIfMounted(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    _initLocationTracking();
    _listenToRescuersFromReport();
  }

  @override
  void dispose() {
    _rtdbSub?.cancel();
    _reportSub?.cancel();
    _positionSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(64, 64)),
        'assets/images/rescuerMarker.png',
      );
      if (mounted) {
        setState(() => _rescuerIcon = icon);
      }
    } catch (_) {
      // Fallback to default marker if asset load fails.
      _rescuerIcon = null;
    }
  }

  Future<void> _initLocationTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setStateIfMounted(
        () =>
            _statusMessage = 'Enable location services to show your position.',
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _setStateIfMounted(() => _statusMessage = 'Location permission denied.');
      return;
    }

    _setStateIfMounted(() => _hasLocationPermission = true);

    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    _setUserLocation(initialPosition, moveCamera: true);

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) => _setUserLocation(position));
  }

  void _setUserLocation(Position position, {bool moveCamera = false}) {
    if (!mounted) return;
    final location = LatLng(position.latitude, position.longitude);
    setState(() {
      _userLocation = location;
      _userCircles = {
        Circle(
          circleId: const CircleId('user_circle'),
          center: location,
          radius: 8,
          fillColor: Colors.blueAccent.withOpacity(0.85),
          strokeColor: Colors.white,
          strokeWidth: 2,
        ),
      };
    });
    if (moveCamera) {
      _moveCamera(location, zoom: 15);
    }
  }

  void _listenToRescuersFromReport() {
    _reportSub = FirebaseFirestore.instance
        .collection('sos_reports')
        .doc(widget.reportId)
        .snapshots()
        .listen(
          (doc) {
            if (!mounted) return;
            final data = doc.data();
            if (data == null) {
              _setStateIfMounted(() {
                _statusMessage = 'Report not found.';
                _rescuerIds = {};
                _loading = false;
              });
              return;
            }

            final ids = List<String>.from(data['rescuers'] ?? const []);
            _setStateIfMounted(() {
              _rescuerIds = ids.toSet();
              _statusMessage = ids.isEmpty ? 'No rescuers assigned yet.' : null;
            });

            _listenToRescuerLocations();
          },
          onError: (_) {
            _setStateIfMounted(() {
              _statusMessage = 'Unable to load report data.';
              _loading = false;
            });
          },
        );
  }

  void _listenToRescuerLocations() {
    _rtdbSub?.cancel();
    if (_rescuerIds.isEmpty) {
      _setStateIfMounted(() {
        _rescuerMarkers.clear();
        _loading = false;
      });
      return;
    }

    _rtdbSub = _database
        .ref('rescuer_locations')
        .onValue
        .listen(
          (event) {
            if (!mounted) return;
            final raw = event.snapshot.value;
            final markers = <Marker>{};
            _rtdbError = null;

            if (raw is Map) {
              raw.forEach((key, value) {
                if (!_rescuerIds.contains(key)) return;
                if (value is! Map) return;

                final lat = _asDouble(value['lat']);
                final lng = _asDouble(value['lng']);
                if (lat == null || lng == null) return;

                final speed = _asDouble(value['speed']);
                final updatedAtMs = _asInt(value['updatedAt']);
                final updatedAt = _toDateTime(updatedAtMs);

                final snippetParts = <String>[];
                if (speed != null) {
                  snippetParts.add('Speed ${speed.toStringAsFixed(1)} m/s');
                }
                if (updatedAt != null) {
                  snippetParts.add('Updated ${_formatTimeAgo(updatedAt)}');
                }

                markers.add(
                  Marker(
                    markerId: MarkerId(key),
                    position: LatLng(lat, lng),
                    infoWindow: InfoWindow(
                      title: 'Rescuer $key',
                      snippet: snippetParts.join(' · '),
                    ),
                    icon:
                        _rescuerIcon ??
                        BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                  ),
                );
              });
            }

            _setStateIfMounted(() {
              _rescuerMarkers
                ..clear()
                ..addAll(markers);
              _loading = false;
              _statusMessage = markers.isEmpty
                  ? (_rtdbError ?? 'Rescuer locations unavailable.')
                  : null;
            });

            _moveCameraToFirstRescuer();
          },
          onError: (error) {
            final message = error is FirebaseException
                ? error.message ?? 'Unable to read rescuer locations.'
                : 'Unable to read rescuer locations.';
            _setStateIfMounted(() {
              _rtdbError = message;
              _statusMessage = message;
              _loading = false;
            });
          },
        );
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _toDateTime(int? milliseconds) {
    if (milliseconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    ).toLocal();
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _moveCameraToFirstRescuer() {
    if (_hasMovedCamera || _rescuerMarkers.isEmpty) return;
    final target = _rescuerMarkers.first.position;
    _moveCamera(target, zoom: 15);
    _hasMovedCamera = true;
  }

  void _moveCamera(LatLng target, {double zoom = 14}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{}..addAll(_rescuerMarkers);
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = _userLocation ?? _defaultLatLng;

    return Scaffold(
      appBar: AppBar(title: const Text('Track Rescuers')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 14,
            ),
            markers: _buildMarkers(),
            circles: _userCircles,
            myLocationEnabled:
                false, // using custom dot instead of default blue
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          ),
          if (_loading || _statusMessage != null)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: _StatusBanner(loading: _loading, message: _statusMessage),
            ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.loading, this.message});

  final bool loading;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!loading && message == null) return const SizedBox.shrink();
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (loading) ...[
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message ?? 'Loading live locations…',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
