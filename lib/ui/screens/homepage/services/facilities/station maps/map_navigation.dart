import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapNavigation extends StatefulWidget {
  final LatLng destination;
  final String destinationName;
  final String destinationMarker;

  const MapNavigation({
    super.key,
    required this.destination,
    required this.destinationName,
    required this.destinationMarker
  });

  @override
  State<MapNavigation> createState() => _MapNavigationState();
}

class _MapNavigationState extends State<MapNavigation> {
  LatLng? _lastRouteUpdate;
  Timer? _routeUpdateTimer;
  final Distance _distance = const Distance();
  LatLng? _userLocation;
  late final MapController _mapController;
  StreamSubscription<Position>? _positionSubscription;
  bool _isFollowing = true;
  List<LatLng> _routePoints = [];
  final String _mapTilerKey = "bRvWPtVFAdDqKNTnifUZ"; // ✅ your API key here

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocationTracking();
  }

  // ✅ Initialize user location tracking
  Future<void> _initLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied'),
        ),
      );
      return;
    }

    // ✅ Get current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final startLocation = LatLng(position.latitude, position.longitude);
    if (mounted) {
      setState(() => _userLocation = startLocation);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(startLocation, 16);
    });

    // ✅ Start continuous tracking
    _startLiveLocationUpdates();

    // ✅ Fetch actual driving route
    _getRoute(startLocation, widget.destination);
  }

  // ✅ Track live user location
  void _startLiveLocationUpdates() {
  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1, // Update every 1 meter movement (more frequent)
    timeLimit: Duration(seconds: 2), // Update at least every 2 seconds
  );

  _positionSubscription =
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
    final newLocation = LatLng(position.latitude, position.longitude);

    if (mounted) {
      setState(() => _userLocation = newLocation);
    }

    // ✅ Smart route updates
    _handleRouteUpdate(newLocation);

    if (_isFollowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(newLocation, _mapController.camera.zoom);
      });
    }
  });
}

void _handleRouteUpdate(LatLng newLocation) {
  // Cancel any pending updates
  _routeUpdateTimer?.cancel();

  // Check if we need to update the route
  final shouldUpdate = _lastRouteUpdate == null ||
      _distance(_lastRouteUpdate!, newLocation) > 100 || // 100 meters
      _isOffRoute(newLocation);

  if (shouldUpdate) {
    _getRoute(newLocation, widget.destination);
    _lastRouteUpdate = newLocation;
  } else {
    // Schedule update for later if not urgent
    _routeUpdateTimer = Timer(const Duration(seconds: 30), () {
      _getRoute(newLocation, widget.destination);
      _lastRouteUpdate = newLocation;
    });
  }
}

bool _isOffRoute(LatLng userLocation) {
  if (_routePoints.length < 2) return false;

  // Find closest point on route
  double minDistance = double.infinity;
  for (final point in _routePoints) {
    final dist = _distance(userLocation, point);
    if (dist < minDistance) {
      minDistance = dist;
    }
  }

  // Consider off-route if more than 50 meters from the path
  return minDistance > 50;
}

  // ✅ Get real driving route using MapTiler Directions API (v2)
  // ✅ Get optimal driving route using OSRM with shortest path
Future<void> _getRoute(LatLng start, LatLng end) async {
  // OSRM automatically finds the fastest route by default
  // For alternative profiles, you can change 'driving' to 'walking' or 'cycling'
  final url =
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&alternatives=false';

  debugPrint('🚀 Fetching optimal route from OSRM: $url');

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('✅ OSRM Response received');

      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final geometry = route['geometry'];
        
        // Log route information
        final distance = (route['distance'] ?? 0) / 1000; // Convert to km
        final duration = (route['duration'] ?? 0) / 60; // Convert to minutes
        
        debugPrint('📍 Route distance: ${distance.toStringAsFixed(2)} km');
        debugPrint('📍 Estimated duration: ${duration.toStringAsFixed(2)} minutes');
        
        if (geometry != null && geometry['coordinates'] != null) {
          final coords = geometry['coordinates'] as List<dynamic>;
          debugPrint('📍 Number of coordinate pairs: ${coords.length}');
          
          if (coords.isNotEmpty) {
            if (mounted) {
              setState(() {
                _routePoints = coords
                    .map((c) => LatLng(
                      c[1] is double ? c[1] : c[1].toDouble(), 
                      c[0] is double ? c[0] : c[0].toDouble()
                    ))
                    .toList();
              });
            }
            
            debugPrint('✅ Optimal route loaded with ${_routePoints.length} points');
            return;
          }
        }
      }
      
      debugPrint('⚠️ No optimal route found in OSRM response');
      
    } else {
      debugPrint('❌ Failed to load optimal route: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('❌ Error fetching optimal route: $e');
  }
  
  // Fallback: create a straight line if API fails
  _createStraightLineRoute(start, end);
}

void _createStraightLineRoute(LatLng start, LatLng end) {
  if (mounted) {
    setState(() {
      _routePoints = [start, end];
    });
  }
  debugPrint('🔄 Using fallback straight line route');
}


  // ✅ Recenter map to user
  void _recenterMap() {
    if (_userLocation == null) return;
    if (mounted) {
      setState(() => _isFollowing = true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_userLocation!, 17);
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(1, 47, 72, 1),
        toolbarHeight: 80,
        title: Text(
          "${widget.destinationName}",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation!,
                initialZoom: 15,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture && _isFollowing && mounted) {
                    setState(() => _isFollowing = false);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$_mapTilerKey',
                  userAgentPackageName: 'com.example.app',
                ),

                // ✅ Polyline route (real driving path)
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),

                // ✅ Markers
                MarkerLayer(
                  markers: [
                    // User marker
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 14,
                      ),
                    ),

                    // Destination marker
                    Marker(
                      point: widget.destination,
                      width: 50,
                      height: 50,
                      child: SvgPicture.asset(
                        widget.destinationMarker,
                        width: 40,
                        height: 40,
                      )
                    ),
                  ],
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _recenterMap,
        tooltip: 'Recenter map',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
