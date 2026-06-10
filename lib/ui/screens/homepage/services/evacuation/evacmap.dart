import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EvacuationMap extends StatelessWidget {
  const EvacuationMap({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(14.5995, 120.9842),
          initialZoom: 19,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=bRvWPtVFAdDqKNTnifUZ',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [         
            ],
          ),
        ],
      );
    
  }
}
