import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';

class Station {
  final String svgpath;
  final String name;
  final String address;
  final LatLng longlath;
  Station({required this.svgpath,required this.name, required this.address, required this.longlath,});
}


class StationsBottomPanel extends StatefulWidget {
  final List<Station> station;
  final Function(Station) onTap;

  const StationsBottomPanel({
    super.key,
    required this.station,
    required this.onTap
    });

  @override
  State<StationsBottomPanel> createState() => _StationsBottomPanelState();
}

class _StationsBottomPanelState extends State<StationsBottomPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: const BoxDecoration(
        color: Color(0xFFE7F1F8), 
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      
      height: _isExpanded ? 260 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Show Stations",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  size: 26,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          
          if (_isExpanded)
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.station.length,
                itemBuilder: (context, index) {
                  final station = widget.station[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => widget.onTap(station),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                       
                            SvgPicture.asset(
                              station.svgpath,
                              width: 35,
                              height: 35,
                              fit: BoxFit.contain,
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    station.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    station.address,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}