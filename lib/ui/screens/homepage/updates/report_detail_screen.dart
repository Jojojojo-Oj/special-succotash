import 'package:agapay_users/ui/screens/homepage/map/track_rescuer_map.dart';
import 'package:agapay_users/ui/screens/homepage/sos/groupchat_screen.dart';
import 'package:agapay_users/ui/screens/homepage/sos/sos_report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportDetailScreen extends StatefulWidget {
  final DocumentSnapshot reportDoc;
  const ReportDetailScreen({super.key, required this.reportDoc});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _reportStream;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _userFuture;
  Map<String, String> _addressCache = {}; // Cache for geocoded addresses

  @override
  void initState() {
    super.initState();
    _reportStream = FirebaseFirestore.instance
        .collection('sos_reports')
        .doc(widget.reportDoc.id)
        .snapshots();
    final senderId =
        (widget.reportDoc.data() as Map<String, dynamic>?)?['senderID']
            as String? ??
        '';
    if (senderId.isNotEmpty) {
      _userFuture = FirebaseFirestore.instance
          .collection('Users')
          .doc(senderId)
          .get();
    }
  }

  /// Reverse geocode coordinates to address
  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    final key = '$latitude,$longitude';

    // Check cache first
    if (_addressCache.containsKey(key)) {
      return _addressCache[key]!;
    }

    try {
      debugPrint('🔍 Geocoding: lat=$latitude, lng=$longitude');
      final placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        debugPrint(
            '✅ Placemark found: street=${p.street}, locality=${p.locality}, postalCode=${p.postalCode}');
        
        final address =
            '${p.street ?? ''}, ${p.locality ?? ''}, ${p.postalCode ?? ''}, ${p.country ?? ''}'
                .replaceAll(RegExp(r',\s*(?=,)'), '')
                .replaceAll(RegExp(r'(^,\s*|,\s*$)'), '')
                .trim();
        
        final finalAddress =
            address.isNotEmpty ? address : 'Coordinates: $latitude, $longitude';
        _addressCache[key] = finalAddress;
        debugPrint('📍 Cached address: $finalAddress');
        return finalAddress;
      } else {
        debugPrint('⚠️ No placemarks found for coordinates, trying fallback...');
        // Fallback: use OpenStreetMap nominatim API
        return await _getAddressFromNominatim(latitude, longitude);
      }
    } catch (e) {
      debugPrint('❌ Geocoding error: $e, trying fallback...');
      return await _getAddressFromNominatim(latitude, longitude);
    }
  }

  /// Fallback reverse geocoding using OpenStreetMap Nominatim
  Future<String> _getAddressFromNominatim(
      double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        
        if (address != null) {
          final streetAddress = address['road'] ?? address['house_number'] ?? '';
          final city = address['city'] ?? address['town'] ?? '';
          final country = address['country'] ?? '';
          
          final fullAddress =
              '$streetAddress, $city, $country'
                  .replaceAll(RegExp(r',\s*(?=,)'), '')
                  .replaceAll(RegExp(r'(^,\s*|,\s*$)'), '')
                  .trim();
          
          final finalAddress = fullAddress.isNotEmpty 
              ? fullAddress 
              : 'Location: $latitude, $longitude';
          
          debugPrint('✅ Got address from Nominatim: $finalAddress');
          _addressCache['$latitude,$longitude'] = finalAddress;
          return finalAddress;
        }
      }
    } catch (e) {
      debugPrint('❌ Nominatim error: $e');
    }
    
    final fallback = 'Location: $latitude, $longitude';
    _addressCache['$latitude,$longitude'] = fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Incident Report',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _reportStream,
        builder: (context, reportSnapshot) {
          final reportData =
              reportSnapshot.data?.data() ??
              widget.reportDoc.data() as Map<String, dynamic>?;
          if (reportData == null) {
            return Center(
              child: Text(
                'Report not found.',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }
          final report = SOSReport.fromMap(
            reportData,
            id: reportSnapshot.data?.id ?? widget.reportDoc.id,
          );

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: _userFuture,
            builder: (context, userSnapshot) {
              final userData = userSnapshot.data?.data();
              final victimName = _buildVictimName(report, userData);
              final phone =
                  userData?['phoneNumber'] as String? ?? 'No phone number';
              final email =
                  userData?['email'] as String? ?? 'No email available';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Victim Information',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVictimCard(report.status, victimName, phone, email),
                    const SizedBox(height: 16),
                    _buildIncidentCard(report),
                    const SizedBox(height: 16),
                    _buildActions(report),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVictimCard(
    String status,
    String name,
    String phone,
    String email,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusBackground(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'STATUS: ${status.toUpperCase()}',
              style: GoogleFonts.poppins(
                color: _statusText(status),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            phone,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(SOSReport report) {
    final incidentCode = report.id?.toUpperCase() ?? '';
    final headerTitle =
        '${report.disasterType.isNotEmpty ? report.disasterType.toUpperCase() : 'INCIDENT'}${incidentCode.isNotEmpty ? ': $incidentCode' : ''}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getDisasterHeaderColor(report.disasterType),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    headerTitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.access_time, 'Time Reported', report.time),
                const SizedBox(height: 12),
                _buildLocationRow(report),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_outlined,
                      color: Colors.red,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Photo Proof',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: report.imagePath.isEmpty
                          ? null
                          : () => _openImage(report.imagePath),
                      child: const Text('View Image'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(SOSReport report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _openGroupChat(report),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black, width: 1.4),
                ),
                child: Text(
                  'Message',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openRescuerMap(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3A52),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Track Rescuer',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.red, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build location row with reverse geocoding
  Widget _buildLocationRow(SOSReport report) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_outlined, color: Colors.red, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              _buildAddressDisplay(report),
            ],
          ),
        ),
      ],
    );
  }

  /// Display address with geocoding fallback
  Widget _buildAddressDisplay(SOSReport report) {
    // Try to extract coordinates from location string
    final coords = _extractCoordinates(report.location);

    if (coords != null) {
      return FutureBuilder<String>(
        future: _getAddressFromCoordinates(coords['lat']!, coords['lng']!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(
              'Loading address...',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            );
          }
          
          if (snapshot.hasError) {
            debugPrint('Error in FutureBuilder: ${snapshot.error}');
            return Text(
              report.location.isNotEmpty ? report.location : 'Not provided',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            );
          }
          
          final address = snapshot.data ?? report.location;
          return Text(
            address.isNotEmpty ? address : 'Not provided',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          );
        },
      );
    }

    debugPrint('❌ Could not extract coordinates from location: ${report.location}');
    return Text(
      report.location.isNotEmpty ? report.location : 'Not provided',
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.grey[700],
      ),
    );
  }

  /// Extract latitude and longitude from location string
  Map<String, double>? _extractCoordinates(String locationStr) {
    try {
      final cleaned = locationStr.replaceAll('"', '').trim();
      final match = RegExp(r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)')
          .firstMatch(cleaned);
      if (match == null) return null;

      final lat = double.tryParse(match.group(1) ?? '');
      final lng = double.tryParse(match.group(2) ?? '');
      if (lat == null || lng == null) return null;
      if (lat.abs() > 90 || lng.abs() > 180) return null;

      return {'lat': lat, 'lng': lng};
    } catch (e) {
      debugPrint('❌ Error extracting coordinates: $e');
    }
    return null;
  }

  String _buildVictimName(SOSReport report, Map<String, dynamic>? userData) {
    final first = userData?['firstName'] as String? ?? '';
    final last = userData?['lastName'] as String? ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    if (report.senderName.isNotEmpty) return report.senderName;
    return 'Unknown Victim';
  }

  Color _getDisasterHeaderColor(String disasterType) {
    final type = disasterType.toLowerCase();
    if (type.contains('fire')) {
      return Colors.red[700] ?? Colors.red;
    } else if (type.contains('volcan') || type.contains('volcano')) {
      return Colors.red[900] ?? Colors.red;
    } else if (type.contains('typhoon') || type.contains('storm')) {
      return Colors.blue[700] ?? Colors.blue;
    } else if (type.contains('tsunami')) {
      return Colors.cyan[800] ?? Colors.cyan;
    } else if (type.contains('police')) {
      return Colors.indigo[700] ?? Colors.indigo;
    } else if (type.contains('medical') || type.contains('assistant')) {
      return Colors.green[700] ?? Colors.green;
    } else if (type.contains('landslide')) {
      return Colors.brown[700] ?? Colors.brown;
    } else if (type.contains('earth') || type.contains('earthquake')) {
      return Colors.orange[700] ?? Colors.orange;
    }
    return Colors.red[700] ?? Colors.red; // Default to red
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green[100] ?? Colors.green;
      case 'pending':
        return Colors.orange[100] ?? Colors.orange;
      case 'done':
        return Colors.blue[100] ?? Colors.blue;
      case 'rejected':
        return Colors.red[100] ?? Colors.red;
      default:
        return Colors.grey[200] ?? Colors.grey;
    }
  }

  Color _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green[800] ?? Colors.green;
      case 'pending':
        return Colors.orange[800] ?? Colors.orange;
      case 'done':
        return Colors.blue[800] ?? Colors.blue;
      case 'rejected':
        return Colors.red[800] ?? Colors.red;
      default:
        return Colors.grey[800] ?? Colors.grey;
    }
  }

  Future<void> _openGroupChat(SOSReport report) async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GroupChatScreen(groupChatId: report.id ?? widget.reportDoc.id),
      ),
    );
  }

  Future<void> _openImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.8,
            maxScale: 4,
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  void _openRescuerMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackRescuerMap(reportId: widget.reportDoc.id),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
