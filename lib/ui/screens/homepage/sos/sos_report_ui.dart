import 'dart:async';
import 'dart:io';
import 'package:agapay_users/ui/screens/homepage/sos/groupchat_moder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:agapay_users/utils/toast_util.dart';
import 'sos_report_model.dart';

class SosReportUi extends StatefulWidget {
  final SOSReport report;

  const SosReportUi({super.key, required this.report});

  @override
  State<SosReportUi> createState() => _SosReportUiState();
}

class _SosReportUiState extends State<SosReportUi> {
  final TextEditingController _detailsController = TextEditingController();
  bool _isSending = false;
  bool _hasInternet = true;
  late final Future<String> _resolvedLocationFuture;
  bool _userConfirmedSend = false; // Track if user explicitly confirmed send
  bool _wasOfflineDuringAttempt = false; // Track if user tried while offline
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _resolvedLocationFuture = _getAddressFromLocation(widget.report.location);
    _checkInternetConnection();
    _setupConnectivityListener();
  }

  Future<String> _getAddressFromLocation(String location) async {
    final coords = _extractCoordinates(location);
    if (coords == null) return location;

    try {
      final placemarks = await placemarkFromCoordinates(coords.$1, coords.$2);
      if (placemarks.isEmpty) return location;

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
      return address.isNotEmpty ? address : location;
    } catch (_) {
      return location;
    }
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
  void dispose() {
    _connectivitySubscription.cancel();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      setState(() {
        _hasInternet = !result.contains(ConnectivityResult.none);
      });
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasInternet = !results.contains(ConnectivityResult.none);
      if (hasInternet != _hasInternet) {
        setState(() {
          _hasInternet = hasInternet;
        });
        
        // Show connection restored message
        if (hasInternet) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Internet connection restored'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // IMPORTANT: Do NOT automatically send SOS when connection is restored
          // Only show that connection is available
          if (_wasOfflineDuringAttempt) {
            // Reset the flag and let user manually retry
            _wasOfflineDuringAttempt = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('You can now send SOS. Press the Send SOS button.'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No internet connection'),
              backgroundColor: Colors.red,
              duration: const Duration(days: 1),
            ),
          );
        }
      }
    });
  }

  Map<String, dynamic> _getDisasterIcon(String type) {
    switch (type.toLowerCase()) {
      case 'earthquake':
        return {'asset': 'assets/images/earthsvg.svg', 'color': Colors.orange};
      case 'medical assistance':
      case 'medical assistant':
      case 'flood': // legacy value
        return {'asset': 'assets/icons/medicalIcon.svg', 'color': const Color(0xFF2E7D32)};
      case 'fire':
        return {'asset': 'assets/images/firesvg.svg', 'color': Colors.red};
      case 'typhoon':
        return {'asset': 'assets/images/typsvg.svg', 'color': Colors.teal};
      case 'landslide':
        return {'asset': 'assets/icons/landslideIcon.svg', 'color': const Color(0xFFA66300)};
      case 'tsunami':
        return {'asset': 'assets/icons/tsunamiIcon.svg', 'color': const Color(0xFF006064)};
      case 'police':
        return {'asset': 'assets/icons/policeIcon.svg', 'color': const Color(0xFF0D47A1)};
      case 'volcano':
      case 'volcanic':
        return {'asset': 'assets/icons/vulcanIcon.svg', 'color': const Color(0xFFB71C1C)};
      default:
        return {'asset': 'assets/icons/default.svg', 'color': Colors.grey};
    }
  }

  Future<void> _sendSOS() async {
    // Reset flags
    _userConfirmedSend = true;
    _wasOfflineDuringAttempt = false;
    
    // Check internet connection first
    if (!_hasInternet) {
      _wasOfflineDuringAttempt = true;
      _showNoInternetDialog();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSending = true);

    try {
      // ✅ Upload image to Firebase Storage
      final file = File(widget.report.imagePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('sos_images/$fileName');
      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();

      // ✅ Create SOS report document
      final sosReport = SOSReport(
        senderID: widget.report.senderID,
        senderName: widget.report.senderName,
        disasterType: widget.report.disasterType,
        disasterIcon: widget.report.disasterIcon,
        location: widget.report.location,
        time: widget.report.time,
        details: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        imagePath: imageUrl,
      );

      final sosRef = await FirebaseFirestore.instance
          .collection('sos_reports')
          .add(sosReport.toMap());

      // ✅ Create top-level group chat document (unified structure)
      final groupChatRef = await FirebaseFirestore.instance
          .collection('group_chats')
          .add({
        'createdBy': widget.report.senderID,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'sosReportId': sosRef.id,
        'rescuers': [],
      });

      // ✅ Seed initial message in unified messages subcollection
      await groupChatRef.collection('messages').add(
        ChatMessage(
          senderId: widget.report.senderID,
          senderName: widget.report.senderName,
          message: "SOS Report created. Rescuers will respond shortly.",
        ).toMap(),
      );

      ToastHelper.showSuccess(context, "SOS Successfully Sent");
      
      // Navigate back to home after successful send
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Check if error is due to no internet
      if (e.toString().contains('UNAVAILABLE') || 
          e.toString().contains('firestore') || 
          e.toString().contains('network') ||
          e.toString().contains('SocketException')) {
        _wasOfflineDuringAttempt = true;
        _showNoInternetDialog();
      } else {
        messenger.showSnackBar(SnackBar(
          content: Text("Error: ${e.toString().split('\n')[0]}"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _userConfirmedSend = false; // Reset confirmation flag
        });
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 10),
            Text('No Internet Connection'),
          ],
        ),
        content: const Text(
          'SOS cannot be sent without internet connection.\n\nPlease check your Wi-Fi or mobile data and try again.',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkInternetConnection();
            },
            child: const Text(
              'Check Connection',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSendingConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Send SOS Report?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will send your SOS report to emergency responders.\n',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade800, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Make sure you have a stable internet connection.',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Send SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Method to handle retake photo with internet check
  Future<void> _retakePhoto() async {
    if (!_hasInternet) {
      _showNoInternetDialog();
      return;
    }

    final picker = ImagePicker();
    final XFile? newPhoto = await picker.pickImage(source: ImageSource.camera);
    if (newPhoto != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SosReportUi(
            report: SOSReport(
              senderID: widget.report.senderID,
              senderName: widget.report.senderName,
              disasterType: widget.report.disasterType,
              disasterIcon: widget.report.disasterIcon,
              location: widget.report.location,
              time: widget.report.time,
              imagePath: newPhoto.path,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getDisasterIcon(widget.report.disasterType);
    final String svgAsset = iconData['asset'] as String;
    final Color bgColor = iconData['color'] as Color;

    return WillPopScope(
      onWillPop: () async {
        // If sending is in progress, prevent going back
        if (_isSending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait, SOS is being sent...'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromRGBO(1, 47, 72, 1),
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (!_isSending) {
                Navigator.pop(context);
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Internet status indicator
              if (!_hasInternet)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.wifi_off,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
              SvgPicture.asset(svgAsset,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              const SizedBox(width: 8),
              Text("Captured Proof",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ),
        body: Column(
          children: [
            // Internet warning banner
            if (!_hasInternet)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'No Internet Connection - SOS cannot be sent',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      onPressed: _checkInternetConnection,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AspectRatio(
                    aspectRatio: 5 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.file(File(widget.report.imagePath),
                              fit: BoxFit.cover, width: double.infinity),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _retakePhoto,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text("Retake",
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Text("Disaster Type:  ",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: bgColor, borderRadius: BorderRadius.circular(8)),
                      child: SvgPicture.asset(svgAsset,
                          width: 20,
                          height: 20,
                          colorFilter:
                              const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    ),
                    const SizedBox(width: 8),
                    Text(widget.report.disasterType,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text("Location:  ",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _resolvedLocationFuture,
                        builder: (context, snapshot) {
                          final address = snapshot.data?.trim();
                          final value =
                              (address != null && address.isNotEmpty)
                                  ? address
                                  : widget.report.location;
                          return Text(
                            value,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text("Time:  ",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(widget.report.time,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ]),
                  const SizedBox(height: 15),
                  Text("Additional Details (optional):",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Describe your situation or if someone is injured...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        // Warning message when offline
                        if (!_hasInternet)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, color: Colors.orange.shade800),
                                const SizedBox(width: 10),
                                Text(
                                  'Connect to internet to send SOS',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSending 
                                ? null 
                                : (_hasInternet ? _showSendingConfirmation : null),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasInternet ? Colors.red : Colors.grey,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!_hasInternet)
                                        const Icon(Icons.wifi_off, size: 24, color: Colors.white),
                                      if (!_hasInternet) const SizedBox(width: 12),
                                      Text(
                                        _hasInternet ? "SEND SOS REPORT" : "NO INTERNET CONNECTION",
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_hasInternet)
                          Text(
                            'Make sure you have a stable internet connection',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}