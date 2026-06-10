import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class OpenStreetMapExample extends StatefulWidget {
  const OpenStreetMapExample({super.key});

  @override
  State<OpenStreetMapExample> createState() => _OpenStreetMapExampleState();
}

class _OpenStreetMapExampleState extends State<OpenStreetMapExample> {
  LatLng? _userLocation;
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  bool _isFollowing = true;
  Position? _lastPosition;
  DateTime? _lastUpdate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, BitmapDescriptor> _markerIcons = {};

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    _initLocationTracking();
  }

  /// Load marker icons from assets
  Future<void> _loadMarkerIcons() async {
    try {
      _markerIcons['earthquake'] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/earthquakeMarker.png',
      );
      _markerIcons['fire'] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/fireMarker.png',
      );
      _markerIcons['typhoon'] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/typhoonMarker.png',
      );
      _markerIcons['landslide'] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/landslideMarker.png',
      );
      _markerIcons['tsunami'] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/tsunamiMarker.png',
      );
      _markerIcons['police'] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/policeMarker.png',
      );
      _markerIcons['volcano'] = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/markers/volcanMarker.png',
      );
      // Create red dot for user location
      _markerIcons['user_location'] = await _createRedDotMarker();
    } catch (e) {
      debugPrint('Error loading marker icons: $e');
    }
  }

  /// Create a red dot marker
  Future<BitmapDescriptor> _createRedDotMarker() async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));
    
    final paint = ui.Paint()..color = Colors.red;
    canvas.drawCircle(const ui.Offset(50, 50), 20, paint);
    
    final image = await recorder.endRecording().toImage(100, 100);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Initialize location tracking safely
  Future<void> _initLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    // Request location permission if needed
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    // Handle permanent denial
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied'),
        ),
      );
      return;
    }

    // ✅ Get initial position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    if (!mounted) return;
    final startLocation = LatLng(position.latitude, position.longitude);
    setState(() => _userLocation = startLocation);

    // ✅ Move map after it's built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _moveMapTo(startLocation, 18);
      }
    });

    // ✅ Start tracking position
    _startLiveLocationUpdates();
  }

  /// Continuously track user location (safe version)
  void _startLiveLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);
      final now = DateTime.now();

      // Throttle updates (every 1 second or 5m)
      if (_lastUpdate != null &&
          now.difference(_lastUpdate!).inMilliseconds < 1000) return;

      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance < 5) return;
      }

      _lastUpdate = now;
      _lastPosition = position;

      if (!mounted) return;
      setState(() => _userLocation = newLocation);

      if (_isFollowing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _moveMapTo(newLocation, 18);
          }
        });
      }
    });
  }

  /// Move map to location
  void _moveMapTo(LatLng location, double zoom) {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }

  /// Recenter map manually
  void _recenterMap() {
    if (_userLocation == null) return;
    setState(() => _isFollowing = true);
    _moveMapTo(_userLocation!, 18);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('sos_reports').snapshots(),
              builder: (context, snapshot) {
                final markers = _getIncidentMarkers(snapshot.data);

                return GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _userLocation!,
                    zoom: 18,
                  ),
                  markers: markers,
                  onCameraMoveStarted: () {
                    if (_isFollowing) {
                      setState(() => _isFollowing = false);
                    }
                  },
                  myLocationEnabled: false,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recenterMap,
        tooltip: 'Recenter map',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Set<Marker> _getIncidentMarkers(
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  ) {
    final markers = <Marker>{};

    // Add user location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: _markerIcons.containsKey('user_location')
              ? _markerIcons['user_location']!
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (snapshot == null || snapshot.docs.isEmpty) {
      return markers;
    }

    int markerIndex = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString().toLowerCase();
      if (status != 'active' && status != 'ongoing') continue;

      final location = _extractLatLng(data);
      if (location == null) continue;

      final disasterType = (data['disasterType'] ?? '').toString();
      
      // Display supported SOS incident types
      if (!_isValidDisasterType(disasterType)) continue;

      final iconKey = _getMarkerIconKey(disasterType);
      if (iconKey == null || !_markerIcons.containsKey(iconKey)) continue;

      markers.add(
        Marker(
          markerId: MarkerId('incident_$markerIndex'),
          position: location,
          infoWindow: InfoWindow(
            title: disasterType.isNotEmpty ? disasterType : 'Incident',
            snippet: 'Status: $status',
          ),
          icon: _markerIcons[iconKey]!,
        ),
      );
      markerIndex++;
    }

    return markers;
  }

  LatLng? _extractLatLng(Map<String, dynamic> data) {
    final geoCandidates = [
      data['position'],
      data['locationGeo'],
      data['geoPoint'],
      data['coordinates'],
      data['location'],
    ];

    for (final candidate in geoCandidates) {
      if (candidate is GeoPoint) {
        return LatLng(candidate.latitude, candidate.longitude);
      }
      if (candidate is Map) {
        final lat = candidate['lat'] ?? candidate['latitude'];
        final lng =
            candidate['lng'] ?? candidate['longitude'] ?? candidate['lon'];
        if (lat is num && lng is num) {
          return LatLng(lat.toDouble(), lng.toDouble());
        }
      }
    }

    final lat = data['lat'] ?? data['latitude'];
    final lng = data['lng'] ?? data['longitude'] ?? data['lon'];
    if (lat is num && lng is num) {
      return LatLng(lat.toDouble(), lng.toDouble());
    }

    final locationStr = data['location'];
    if (locationStr is String && locationStr.contains(',')) {
      final parts = locationStr.split(',').map((s) => s.trim()).toList();
      if (parts.length >= 2) {
        final parsedLat = double.tryParse(parts[0]);
        final parsedLng = double.tryParse(parts[1]);
        if (parsedLat != null && parsedLng != null) {
          return LatLng(parsedLat, parsedLng);
        }
      }
    }

    return null;
  }

  bool _isValidDisasterType(String disasterType) {
    final type = disasterType.toLowerCase();
    return type.contains('earth') || 
           type.contains('fire') || 
           (type.contains('typhoon') || type.contains('storm')) ||
           type.contains('landslide') ||
           type.contains('tsunami') ||
           type.contains('police') ||
           type.contains('volcan') ||
           type.contains('volcano');
  }

  String? _getMarkerIconKey(String disasterType) {
    final type = disasterType.toLowerCase();
    if (type.contains('earth')) {
      return 'earthquake';
    }
    if (type.contains('fire')) {
      return 'fire';
    }
    if (type.contains('typhoon') || type.contains('storm')) {
      return 'typhoon';
    }
    if (type.contains('landslide')) {
      return 'landslide';
    }
    if (type.contains('tsunami')) {
      return 'tsunami';
    }
    if (type.contains('police')) {
      return 'police';
    }
    if (type.contains('volcan') || type.contains('volcano')) {
      return 'volcano';
    }
    return null;
  }
}
