import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/map_navigation.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/marker_popup.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/stations_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class PoliceMap extends StatefulWidget {
  const PoliceMap({super.key});

  @override
  State<PoliceMap> createState() => _PoliceMapState();
}

class _PoliceMapState extends State<PoliceMap> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  
  final LatLng _initialCenter = const LatLng(14.640153089287482, 120.96940312056547);
  final double _initialZoom = 19.0;
  static const  String svgpath = "assets/images/police_map_icon.svg";

  final List<Station> stations = [
    Station(svgpath: svgpath , name: "Caloocan City Police Station", address: "31 Tuna St, Maypajo, Caloocan, 1400 Metro Manila", longlath: LatLng(14.640153089287482, 120.96940312056547)),
    Station(svgpath: svgpath , name: "Northern Police District Office", address: "7025 Dagat-Dagatan Ave, Poblacion, Caloocan City", longlath: LatLng(14.648235716361901, 120.96883274119992)),
    Station(svgpath: svgpath , name: "Caloocan City Police Station (Main / South Headquarters)", address: "Samson Road, Barangay 80, Sangandaan, Caloocan City", longlath: LatLng(14.657739240751548, 120.97443555772217)),
    Station(svgpath: svgpath , name: "Police Station 1", address: "Samson Rd, Sangandaan, Caloocan City", longlath: LatLng(14.657541369258379, 120.9752809502557)),
    Station(svgpath: svgpath , name: "Police- Sub Station 1", address: "Malolos Ave, Bagong Barrio West, Caloocan City", longlath: LatLng(14.66452267916946, 120.99622113320636)),
    Station(svgpath: svgpath , name: "Police- Sub Station 2", address: "C3 Road, 8th Street, de Jesus, Caloocan City", longlath: LatLng(14.644403583115361, 120.9899538670059)),
    Station(svgpath: svgpath , name: "Police- Sub Station 3", address: "9th Avenue corner A. Del Mundo Street, Grace Park, Caloocan City", longlath: LatLng(14.650374067222875, 120.98220777479781)),
    Station(svgpath: svgpath , name: "Police- Sub Station 4", address: "General San Miguel St, Sangandaan, Caloocan City", longlath: LatLng(14.658236374788308, 120.97081941951454))
    
  ];

  @override
  Widget build(BuildContext context) {
     final List<Marker> markers = stations.map((station) {
      return Marker(
        point: station.longlath,
        width: 50,
        height: 50,
        child: SvgPicture.asset(
          "assets/images/police_marker_icon.svg",
          width: 40,
          height: 40,
        ),
      );
    }).toList();
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(1, 47, 72, 1),
        toolbarHeight: 80,
        title: Text(
          "Emergency Facility Map",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      // BODY
      body:  Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              onTap: (_, __) => _popupController.hideAllPopups(),
              interactionOptions:
                  const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              // 🌍 Base Map
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=bRvWPtVFAdDqKNTnifUZ',
                userAgentPackageName: 'com.example.app',
              ),

              // 
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  popupController: _popupController,
                  markers: markers,
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                      final station = stations.firstWhere(
                        (s) => s.longlath == marker.point,
                      );

                      return MarkerPopup(
                      name: station.name,
                      address: station.address,
                      location: station.longlath,
                      onFocusTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => MapNavigation(destination: station.longlath,destinationName: station.name, destinationMarker: svgpath,)));
                      },
                    );
                    },
                  ),
                ),
              ),
            ],
          ),

          
          Align(
            alignment: Alignment.bottomCenter,
            child: StationsBottomPanel(
              station: stations,
              onTap: (station) {
                _popupController.hideAllPopups();
                _mapController.move(station.longlath, 17);
              },
            ),
          ),
        ],
      ),
    );
  }
}


