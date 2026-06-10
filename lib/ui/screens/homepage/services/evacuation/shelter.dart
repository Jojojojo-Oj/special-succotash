import 'package:flutter/material.dart';

class Shelter {
  final String name;
  final String address;

  Shelter({required this.name, required this.address});
}

class ShelterBottomPanel extends StatefulWidget {
  final List<Shelter> shelters;
  final Function(Shelter) onTap;

  const ShelterBottomPanel({
    super.key,
    required this.shelters,
    required this.onTap,
  });

  @override
  State<ShelterBottomPanel> createState() => _ShelterBottomPanelState();
}

class _ShelterBottomPanelState extends State<ShelterBottomPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: const BoxDecoration(
        color: Color(0xFFE7F1F8), // light blueish background like screenshot
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
      // Adjust height based on expansion
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
                  "Show Shelters",
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
                itemCount: widget.shelters.length,
                itemBuilder: (context, index) {
                  final shelter = widget.shelters[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => widget.onTap(shelter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFF012F48), size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shelter.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shelter.address,
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
