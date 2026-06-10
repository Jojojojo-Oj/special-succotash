import 'dart:io';
import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class SelfiePanel extends StatefulWidget {
  const SelfiePanel({
    super.key,
    required this.controller,
    required this.data,
  });

  final PageController controller;
  final RegistrationData data;

  @override
  State<SelfiePanel> createState() => _SelfiePanelState();
}

class _SelfiePanelState extends State<SelfiePanel> {
  String? _selfiePath; // ✅ store selfie as String path
  bool _isCapturing = false;

  Future<void> _captureSelfie() async {
    setState(() => _isCapturing = true);

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front, // front camera
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (picked != null) {
        setState(() {
          _selfiePath = picked.path;
          widget.data.selfiePath = _selfiePath!; // ✅ save to model
        });
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Widget _buildUploadBox({
    required String label,
    required IconData icon,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black26),
            ),
            child: _isCapturing
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF012F48),
                    ),
                  )
                : imagePath == null
                    ? Center(
                        child: Icon(icon, color: Colors.black54, size: 60),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _captureSelfie,
                                  tooltip: "Retake Selfie",
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
    final isButtonEnabled = _selfiePath != null && !_isCapturing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            "Take a Selfie",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please take a clear selfie to verify your identity.",
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          _buildUploadBox(
            label: "Your Selfie",
            icon: Icons.camera_alt_outlined,
            imagePath: _selfiePath,
            onTap: _captureSelfie,
          ),

          const Spacer(),

          SizedBox(
            width: 340,
            height: 65,
            child: OutlinedButton(
              onPressed: isButtonEnabled
                  ? () {
                      widget.data.selfiePath = _selfiePath!;
                      print("${widget.data.firstName}, ${widget.data.lastName}, ${widget.data.email}, ${widget.data.phoneNumber},${widget.data.birthday}, ${widget.data.selfiePath}");
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
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Next",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
