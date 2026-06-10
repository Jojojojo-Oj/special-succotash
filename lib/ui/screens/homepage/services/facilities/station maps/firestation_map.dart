import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/map_navigation.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/marker_popup.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/stations_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class FirestationMap extends StatefulWidget {
  const FirestationMap({super.key});

  @override
  State<FirestationMap> createState() => _FirestationMapState();
}

class _FirestationMapState extends State<FirestationMap> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  
  final LatLng _initialCenter = const LatLng(14.65778226985275, 120.97431559725541);
  final double _initialZoom = 19.0;
  static const  String svgpath = "assets/images/firestation_map_icon.svg";




  final List<Station> stations = [
    Station(svgpath: svgpath , name: "Caloocan City Central Fire Station", address: "Samson Rd, Caloocan City", longlath: LatLng(14.65778226985275, 120.97431559725541)),
    Station(svgpath: svgpath , name: "Bagong Barrio Fire Station", address: "129 Malolos Ave, Bagong Barrio West, Caloocan City", longlath: LatLng(14.66451178838572, 120.99613396199244)),
    Station(svgpath: svgpath , name: "Maypajo Fire Sub-Station", address: "J.P Rizal St, Maypajo, Caloocan City", longlath: LatLng(14.63799591072465, 120.97367435683583)),
    Station(svgpath: svgpath , name: "4th Avenue Fire Sub Station", address: "4th Ave, Grace Park West, Caloocan City", longlath: LatLng(14.643865960206604, 120.9820047879442)),
    Station(svgpath: svgpath , name: "Barrio San Jose Fire Sub-Station", address: "Tagaytay Street, Brgy. 128 , San Jose ,Caloocan City", longlath: LatLng(14.63997910535507, 120.98915572523623)),
    
    
  ];

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = stations.map((station) {
      return Marker(
        point: station.longlath,
        width: 50,
        height: 50,
        child: SvgPicture.asset(
          "assets/images/firestation_marker_icon.svg",
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
      body: Stack(
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