import 'package:agapay_users/ui/screens/homepage/updates/report_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final Map<String, String> _addressCache = {};

  Future<String> _resolveAddress(String location) async {
    final coordinates = _extractCoordinates(location);
    if (coordinates == null) return location;

    final key = '${coordinates.$1},${coordinates.$2}';
    if (_addressCache.containsKey(key)) {
      return _addressCache[key]!;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.$1,
        coordinates.$2,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ]
            .where((part) => part != null && part.trim().isNotEmpty)
            .map((part) => part!.trim())
            .toList();

        final address = parts.join(', ');
        final value = address.isNotEmpty ? address : location;
        _addressCache[key] = value;
        return value;
      }
    } catch (_) {}

    _addressCache[key] = location;
    return location;
  }

  (double, double)? _extractCoordinates(String value) {
    final match = RegExp(r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)')
        .firstMatch(value);
    if (match == null) return null;

    final lat = double.tryParse(match.group(1) ?? '');
    final lng = double.tryParse(match.group(2) ?? '');
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;

    return (lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Text(
            "You need to log in to view your reports.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sos_reports')
            .where('senderID', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "You haven’t reported any incidents yet.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            );
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final disasterType = report['disasterType'] ?? 'Unknown';
              final location = report['location'] ?? 'Unknown location';
              final details = report['details'] ?? 'No details provided.';
              final imagePath = report['imagePath'] ?? '';
              final time = report['time'] ?? '';
              final status = report['status'] ?? 'pending';

              // 🔹 Set colors based on status
              Color? bgColor;
              Color? textColor;

              switch (status) {
                case 'active':
                  bgColor = Colors.green[100];
                  textColor = Colors.green[800];
                  break;
                case 'rejected':
                  bgColor = Colors.red[100];
                  textColor = Colors.red[800];
                  break;
                case 'done':
                  bgColor = Colors.blue[100];
                  textColor = Colors.blue[800];
                  break;
                default: // pending
                  bgColor = Colors.grey[200];
                  textColor = Colors.grey[800];
              }

              final double cardOpacity = status == 'active' ? 1.0 : 0.85;

              return Opacity(
                opacity: cardOpacity,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReportDetailScreen(reportDoc: report),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                disasterType,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 🔹 Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: FutureBuilder<String>(
                                  future: _resolveAddress(location),
                                  builder: (context, addressSnapshot) {
                                    final address = addressSnapshot.data;
                                    final value =
                                        (address != null &&
                                            address.trim().isNotEmpty)
                                        ? address
                                        : location;
                                    return Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 🔹 Details
                          Text(
                            details,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 🔹 Image (if available)
                          if (imagePath.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imagePath,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 10),

                          // 🔹 Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                time,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: (textColor ?? Colors.grey).withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
