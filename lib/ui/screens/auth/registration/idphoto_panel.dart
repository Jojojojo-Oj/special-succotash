import 'dart:io';
import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class VerifyIDPanel extends StatefulWidget {
  const VerifyIDPanel({
    super.key,
    required this.controller,
    required this.data,
  });

  final PageController controller;
  final RegistrationData data;

  @override
  State<VerifyIDPanel> createState() => _VerifyIDPanelState();
}

class _VerifyIDPanelState extends State<VerifyIDPanel> {
  String? _idFrontPath;
  String? _idBackPath;

  Future<void> _pickImage({required bool isFront}) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );

    if (picked != null) {
      setState(() {
        if (isFront) {
          _idFrontPath = picked.path;
          widget.data.idPath = _idFrontPath!; // ✅ Save to model
        } else {
          _idBackPath = picked.path;
          widget.data.idBackPath = _idBackPath!; // ✅ Save to model
        }
      });
    }
  }

  Widget _buildUploadBox({
    required String label,
    required IconData icon,
    required String? imagePath,
    required VoidCallback onTap,
    required VoidCallback onRetake,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black26),
            ),
            child: imagePath == null
                ? Center(
                    child: Icon(icon, color: Colors.black54, size: 40),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(imagePath), fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white, size: 20),
                              onPressed: onRetake,
                              tooltip: "Retake",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled =
        _idFrontPath != null && _idBackPath != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              "We need to verify you",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              "Please upload a valid ID so we can confirm your identity.",
              style: GoogleFonts.inter(
                  fontSize: 15, color: Colors.grey, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            _buildUploadBox(
              label: "Front of ID",
              icon: Icons.badge_outlined,
              imagePath: _idFrontPath,
              onTap: () => _pickImage(isFront: true),
              onRetake: () => _pickImage(isFront: true),
            ),

            const SizedBox(height: 16),

            _buildUploadBox(
              label: "Back of ID",
              icon: Icons.credit_card,
              imagePath: _idBackPath,
              onTap: () => _pickImage(isFront: false),
              onRetake: () => _pickImage(isFront: false),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 340,
              height: 65,
              child: OutlinedButton(
                onPressed: isButtonEnabled
                    ? () {
                        widget.data.idPath = _idFrontPath!;
                        widget.data.idBackPath = _idBackPath!;
                        widget.controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isButtonEnabled
                      ? const Color.fromARGB(255, 6, 37, 53)
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  "Next",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
