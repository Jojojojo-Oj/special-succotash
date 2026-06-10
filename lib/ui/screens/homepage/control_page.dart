import 'dart:async';

import 'package:agapay_users/ui/screens/homepage/sos/sos_report_model.dart';
import 'package:agapay_users/ui/screens/homepage/sos/sos_report_ui.dart';
import 'package:agapay_users/ui/screens/emergency_mode/emergency.dart';
import 'package:agapay_users/ui/screens/homepage/updates/announcement_controller.dart';
import 'package:agapay_users/ui/screens/homepage/map/maps.dart';
import 'package:agapay_users/ui/screens/homepage/profile/profile.dart';
import 'package:agapay_users/ui/screens/homepage/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Safe wrapper for Updates with offline support
class SafeUpdatesContent extends StatefulWidget {
  const SafeUpdatesContent({super.key});

  @override
  State<SafeUpdatesContent> createState() => _SafeUpdatesContentState();
}

class _SafeUpdatesContentState extends State<SafeUpdatesContent> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    if (!mounted) return;
    setState(() {
      _isOffline = result.contains(ConnectivityResult.none);
    });
    
    if (!_isOffline) {
      _loadUpdates();
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No internet connection';
      });
    }
  }

  Future<void> _loadUpdates() async {
    try {
      // Add timeout to prevent hanging
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      // Try to create the Updates content with error handling
      // If SegmentedButtonDemo uses Firestore, it will throw an error when offline
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('Error loading Updates: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().contains('firestore')
            ? 'Unable to connect to server. Please check your internet connection.'
            : 'Failed to load updates. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isOffline ? Icons.wifi_off : Icons.error_outline,
                  size: 64,
                  color: _isOffline ? Colors.orange : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  _isOffline ? 'No Internet Connection' : 'Connection Error',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _checkConnectivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                
              ],
            ),
          ),
        ),
      );
    }

    // Try to load the actual Updates content
    try {
      return const SegmentedButtonDemo();
    } catch (e) {
      print('Error in SegmentedButtonDemo: $e');
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Failed to load Updates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Error: ${e.toString().split('\n')[0]}', // Show only first line
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUpdates,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  String _title = "AGAPAY";
  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _isConnected = true;
  bool _isEmergencyMode = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  // Updated contents with safe wrapper for Updates
  final List<Widget> _contents = [
    const OpenStreetMapExample(),
    const ServicesContent(),
    const SafeUpdatesContent(), // Using safe wrapper
    ProfileContent(),
  ];

  final List<String> _pageTitles = [
    "AGAPAY",
    "Services",
    "Updates",
    "My Profile",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initConnectivity();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectivity();
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      setState(() {
        _isConnected = !result.contains(ConnectivityResult.none);
      });
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected != _isConnected) {
        setState(() {
          _isConnected = isConnected;
        });
        
        _showConnectionSnackbar(isConnected);
        
        // Refresh Updates content when connection is restored
        if (isConnected && _selectedIndex == 2) {
          // You could trigger a refresh here if needed
        }
      }
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = !result.contains(ConnectivityResult.none);
      if (isConnected != _isConnected) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  void _showConnectionSnackbar(bool isConnected) {
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.hideCurrentSnackBar();
    
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              isConnected ? 'Internet connection restored' : 'No internet connection',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        duration: isConnected ? const Duration(seconds: 2) : const Duration(days: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<bool> _confirmEmergencyMode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enable Emergency Mode', 
          style: TextStyle(color: Colors.red),),
          content: const Text(
            'Are you sure you want to turn on Emergency Mode?',
           
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _openEmergencyModeScreen() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.red,
          body: SafeArea(
            child: EmergencyOverlay(
              onSendSOS: () {},
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Improved helper function to get current coordinates with better error handling
  Future<String> _getCurrentCoordinates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable location services.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied. Please grant location permission in app settings.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permission permanently denied. Please enable location permissions in your device settings.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      return "${position.latitude}, ${position.longitude}";
    } catch (e) {
      throw 'Failed to get location: ${e.toString()}';
    }
  }

  // ✅ Helper function to get user data from Firestore with offline handling
  Future<Map<String, String>> _getUserData() async {
    try {
      // Check internet first
      if (!_isConnected) {
        throw 'No internet connection. Please connect to the internet to fetch user data.';
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 10));

      if (!userDoc.exists) {
        throw 'User data not found';
      }

      final data = userDoc.data() as Map<String, dynamic>;
      return {
        'firstName': data['firstName']?.toString() ?? '',
        'lastName': data['lastName']?.toString() ?? '',
      };
    } catch (e) {
      if (e.toString().contains('firestore') || e.toString().contains('UNAVAILABLE')) {
        throw 'Unable to connect to server. Please check your internet connection.';
      }
      throw 'Failed to fetch user data: ${e.toString()}';
    }
  }

  // ✅ Check internet before SOS
  void _checkInternetBeforeSOS() {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please check your network.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    _showSOSBottomSheet();
  }

  // ✅ Handle SOS emergency selection
  void _handleEmergencySelection(Map<String, dynamic> emergency) async {
    if (_isLoading) return;

    // Check internet connection first
    if (!_isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. SOS cannot be sent.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Navigator.pop(context); // Close bottom sheet first

      // Get image from camera
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) {
        // User cancelled camera
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current time
      final now = DateTime.now();
      final formattedTime =
          "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

      // Get coordinates and user data concurrently
      final results = await Future.wait([
        _getCurrentCoordinates(),
        _getUserData(),
      ], eagerError: true);

      final coordinates = results[0] as String;
      final userData = results[1] as Map<String, String>;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'Please log in to send an SOS report.';
      }

      // Create SOS Report object
      final report = SOSReport(
        senderID: user.uid,
        senderName: '${userData['firstName']} ${userData['lastName']}',
        disasterType: emergency['title'] as String,
        disasterIcon: emergency['icon'] as String,
        location: coordinates,
        time: formattedTime,
        imagePath: photo.path,
      );

      // Navigate to SOS report UI
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SosReportUi(report: report),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Show SOS emergency selection bottom sheet
  void _showSOSBottomSheet() {
    final emergencies = [
      {
        'title': 'Typhoon',
        'icon': 'assets/images/floodsvg.svg',
        'image': 'assets/images/typhoon.png',
        'color': Colors.teal,
      },
      {
        'title': 'Fire',
        'icon': 'assets/images/firesvg.svg',
        'image': 'assets/images/fire.png',
        'color': Colors.red,
      },
      {
        'title': 'Earthquake',
        'icon': 'assets/images/earthsvg.svg',
        'image': 'assets/images/earthquake.png',
        'color': Colors.orange,
      },
      {
        'title': 'Medical Assistance',
        'icon': 'assets/icons/medicalIcon.svg',
        'image': 'assets/images/medicalPic.png',
        'color': const Color(0xFF2E7D32),
      },
      {
        'title': 'Landslide',
        'icon': 'assets/icons/landslideIcon.svg',
        'image': 'assets/images/landslidePic.png',
        'color': const Color(0xFFA66300),
      },
      {
        'title': 'Police',
        'icon': 'assets/icons/policeIcon.svg',
        'image': 'assets/images/policePic.png',
        'color': const Color(0xFF0D47A1),
      },
      {
        'title': 'Volcano',
        'icon': 'assets/icons/vulcanIcon.svg',
        'image': 'assets/images/volcanPic.png',
        'color': const Color(0xFFB71C1C),
      },
      {
        'title': 'Tsunami',
        'icon': 'assets/icons/tsunamiIcon.svg',
        'image': 'assets/images/tsunamiPic.png',
        'color': const Color(0xFF006064),
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final bottomSheetHeight = (screenHeight * 0.88).clamp(560.0, 700.0);

        return Container(
          height: bottomSheetHeight.toDouble(),
          decoration: const BoxDecoration(
            color: Color(0xFF062B4C),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Select Type of Emergency",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Emergency Type Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.45,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: emergencies.length,
                    itemBuilder: (context, index) {
                      final emergency = emergencies[index];
                      final bgColor = emergency['color'] as Color;

                      return GestureDetector(
                        onTap: () => _handleEmergencySelection(emergency),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(emergency['image'] as String),
                              fit: BoxFit.cover,
            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: bgColor.withOpacity(0.4),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon container
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: _buildEmergencySvgIcon(
                                      emergency['icon'] as String,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Emergency title
                                Text(
                                  emergency['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
              ),
              // Bottom instruction
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _isConnected ? "Select Type of Emergency" : "No Internet - SOS Unavailable",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencySvgIcon(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      width: 36,
      height: 36,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => const Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 5),
          child: _selectedIndex == 0 ? Image.asset("assets/images/logo.png") : null,
        ),
        actions: [
          Center(
            child: Text(
              'EMGY',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _selectedIndex == 0 ? Colors.red : Colors.white,
              ),
            ),
          ),
          Switch.adaptive(
            value: _isEmergencyMode,
            onChanged: (value) async {
              if (!value) {
                setState(() => _isEmergencyMode = false);
                return;
              }

              final confirmed = await _confirmEmergencyMode();
              if (!mounted) return;
              if (!confirmed) {
                setState(() => _isEmergencyMode = false);
                return;
              }

              setState(() => _isEmergencyMode = true);
              await _openEmergencyModeScreen();
              if (!mounted) return;
              setState(() => _isEmergencyMode = false);
            },
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true,
        backgroundColor: _selectedIndex == 0 
            ? Colors.white 
            : const Color.fromRGBO(1, 47, 72, 1),
        toolbarHeight: 80,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isConnected)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.wifi_off,
                  size: 20,
                  color: _selectedIndex == 0 ? Colors.red : Colors.orange,
                ),
              ),
            Text(
              _pageTitles[_selectedIndex],
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: _selectedIndex == 0 ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _contents[_selectedIndex],
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          // Network status banner at top
          if (!_isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.red,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'No Internet Connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 🔹 Bottom nav bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton(
                      index: 0,
                      icon: Icons.home,
                      onPressed: () => _onNavItemTapped(0),
                    ),
                    _buildNavButton(
                      index: 1,
                      icon: Icons.medical_services,
                      onPressed: () => _onNavItemTapped(1),
                    ),
                    const SizedBox(width: 40), // Space for SOS button
                    _buildNavButton(
                      index: 2,
                      icon: Icons.wifi_tethering,
                      onPressed: () => _onNavItemTapped(2),
                    ),
                    _buildNavButton(
                      index: 3,
                      icon: Icons.person,
                      onPressed: () => _onNavItemTapped(3),
                    ),
                  ],
                ),
              ),
            ),
            // 🔴 SOS BUTTON
            Positioned(
              top: -30,
              child: _buildSOSButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required int index,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () {
        try {
          onPressed();
        } catch (e) {
          print('Error navigating to index $index: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading ${_pageTitles[index]}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      icon: Icon(isSelected ? icon : _getOutlinedIcon(icon)),
      color: isSelected ? const Color(0xFF012F48) : Colors.black26,
      iconSize: 28,
    );
  }

  IconData _getOutlinedIcon(IconData filledIcon) {
    switch (filledIcon) {
      case Icons.home:
        return Icons.home_outlined;
      case Icons.medical_services:
        return Icons.medical_services_outlined;
      case Icons.wifi_tethering:
        return Icons.wifi_tethering_outlined;
      case Icons.person:
        return Icons.person_outline;
      default:
        return filledIcon;
    }
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _checkInternetBeforeSOS,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: _isLoading ? Colors.grey : (_isConnected ? Colors.red : Colors.grey),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isConnected)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    Text(
                      'SOS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}