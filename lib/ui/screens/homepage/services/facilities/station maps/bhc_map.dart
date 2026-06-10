import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/map_navigation.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/stations_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'marker_popup.dart';

class BhcMap extends StatefulWidget {
  const BhcMap({super.key});

  @override
  State<BhcMap> createState() => _BhcMapState();
}

class _BhcMapState extends State<BhcMap> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  final LatLng _initialCenter = const LatLng(14.6503, 120.9843);
  final double _initialZoom = 15.5;
  static const String svgpath = "assets/images/bhc_map_icon.svg";

  final List<Station> stations = [
    Station(
      svgpath: svgpath,
      name: "Grace Park Health Center",
      address: "3rd Street, 9th Ave, Grace Park East, Caloocan City",
      longlath: LatLng(14.6503, 120.9843),
    ),
    Station(
      svgpath: svgpath,
      name: "Calaanan ABTC Health Center",
      address:
          "113 L. Nadurata Street, 7th Ave, Grace Park West, Caloocan City",
      longlath: LatLng(14.647724340477412, 120.97864871423712),
    ),
    Station(
      svgpath: svgpath,
      name: "Sampalukan Health Center",
      address: "Perpetua Street, Sampalukan, Caloocan City",
      longlath: LatLng(14.6438997, 120.9737603),
    ),
    Station(
      svgpath: svgpath,
      name: "Barrio San Jose Health Center",
      address: "580 Tagaytay St, Grace Park East, Caloocan City",
      longlath: LatLng(14.639754118333961, 120.98903004057844),
    ),
    Station(
      svgpath: svgpath,
      name: "Barangay 120 Health Center",
      address:
          "Grace Park, 2nd Street, 192 2nd Ave, Grace Park East, Caloocan City",
      longlath: LatLng(14.6403496, 120.9816485),
    ),
    Station(
      svgpath: svgpath,
      name: "E. Rodriguez Health Center",
      address: "Violeta, Grace Park East, Caloocan, Metro Manila",
      longlath: LatLng(14.6527305, 120.9937377),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = stations.map((station) {
      return Marker(
        point: station.longlath,
        width: 50,
        height: 50,
        child: SvgPicture.asset(
          "assets/images/bhc_marker_icon.svg",
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

      //  MAP BODY
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
