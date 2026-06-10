import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/map_navigation.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/marker_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/stations_list.dart';

class HospitalMap extends StatefulWidget {
  const HospitalMap({super.key});

  @override
  State<HospitalMap> createState() => _HospitalMapState();
}

class _HospitalMapState extends State<HospitalMap> {
  
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  final LatLng _initialCenter = const LatLng(14.648199288065925, 120.9734835094816);
  final double _initialZoom = 19.0;
  static const  String svgpath = "assets/images/hospital_map_icon.svg";

  

  final List<Station> stations = [
    Station(svgpath: svgpath , name: "Caloocan City Medical Center (South)", address: "450 A. Mabini St, Poblacion, Caloocan City",longlath: LatLng(14.648199288065925, 120.9734835094816)),
    Station(svgpath: svgpath , name: "Martinez Memorial Hospital, Inc.", address: "198 A. Mabini Street, Maypajo, Caloocan City,", longlath: LatLng(14.63882308608873, 120.97604245114644)),
    Station(svgpath: svgpath , name: "Our Lady of Grace Hospital", address: "8th Avenue cor. F. Roxas St., Grace Park, Caloocan City", longlath: LatLng(14.649138387954524, 120.98173134202284)),
    Station(svgpath: svgpath , name: "Manila Central University Hospital", address: "MCU Hospital, Morning Breeze Subdivision, Caloocan City", longlath: LatLng(14.65755498326319, 120.9871405697384) )
    
  ];

  @override
  Widget build(BuildContext context) {

    final List<Marker> markers = stations.map((station) {
      return Marker(
        point: station.longlath,
        width: 50,
        height: 50,
        child: SvgPicture.asset(
          "assets/images/hospital_marker_icon.svg",
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