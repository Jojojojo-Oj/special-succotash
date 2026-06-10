import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  File? _profileImage;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔥 Fetch data from Firestore
  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data()!;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      setState(() => isLoading = false);
    }
  }

  // 📸 Pick image from camera and upload to Firebase Storage
  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      isLoading = true;
      _profileImage = File(pickedFile.path);
    });

    try {
      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('selfie.jpg');

      await ref.putFile(_profileImage!);
      final downloadUrl = await ref.getDownloadURL();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update({'selfieUrl': downloadUrl});

      setState(() {
        userData!['selfieUrl'] = downloadUrl;
        isLoading = false;
      });

      _showProfileUpdatedPopup();
    } catch (e) {
      debugPrint("Error uploading image: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ Show popup after saving
  void _showProfileUpdatedPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE7F5FC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8F0FB),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.close, size: 20, color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SvgPicture.asset('assets/images/prof_updated.svg', width: 110, height: 110),
                const SizedBox(height: 15),
                const Text(
                  "Profile Updated!",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF012F48),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your selfie has been updated and saved\nsuccessfully to your profile.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 200,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF012F48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF012F48))),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("No user data found.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Personal Information",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👤 Profile image
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE9F1FB),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : userData!['selfieUrl'] != null
                            ? Image.network(userData!['selfieUrl'], fit: BoxFit.cover)
                            : Icon(Icons.person, color: Colors.grey[400], size: 60),
                  ),
                ),
                GestureDetector(
                  onTap: _pickImageFromCamera,
                  child: Container(
                    width: 34,
                    height: 34,
                    child: Center(
                      child: SvgPicture.asset('assets/images/edit.svg', width: 40, height: 40),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _buildLabel("Name"),
            _buildDisabledTextField(userData!['firstName'] ?? "First Name"),
            _buildDisabledTextField(userData!['lastName'] ?? "Last Name"),

            _buildLabel("Gender"),
            _buildDisabledTextField(userData!['gender'] ?? ""),

            _buildLabel("Phone"),
            _buildDisabledTextField(userData!['phoneNumber'] ?? ""),

            _buildLabel("Address"),
            _smallLabel("Region"),
            _buildDisabledTextField(userData!['region'] ?? ""),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _smallLabel("Province"),
                      _buildDisabledTextField(userData!['province'] ?? ""),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _smallLabel("City"),
                      _buildDisabledTextField(userData!['city'] ?? ""),
                    ],
                  ),
                ),
              ],
            ),

            _smallLabel("Barangay"),
            _buildDisabledTextField(userData!['brgy'] ?? ""),

            _smallLabel("Street / House No. / Building"),
            _buildDisabledTextField(userData!['streetHouseBuilding'] ?? ""),

            const SizedBox(height: 30),

            SizedBox(
              width: 350,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF012F48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _showProfileUpdatedPopup,
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏷 Labels
  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      );

  Widget _smallLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 8),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      );

  Widget _buildDisabledTextField(String value) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: TextField(
          enabled: false,
          readOnly: true,
          decoration: InputDecoration(
            hintText: value,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.black87,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}
