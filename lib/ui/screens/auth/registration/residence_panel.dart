import 'dart:io';
import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:agapay_users/ui/screens/auth/verification/verification_page.dart';
import 'package:agapay_users/ui/widgets/TextFieldWidget.dart';
import 'package:agapay_users/utils/toast_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResidencePanel extends StatefulWidget {
  final PageController controller;
  final RegistrationData data;

  const ResidencePanel({
    super.key,
    required this.controller,
    required this.data,
  });

  @override
  State<ResidencePanel> createState() => _ResidencePanelState();
}

class _ResidencePanelState extends State<ResidencePanel> {
  late TextEditingController regionController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController barangayController;
  late TextEditingController sthController;

  bool _isChecked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    regionController = TextEditingController();
    provinceController = TextEditingController();
    cityController = TextEditingController();
    barangayController = TextEditingController();
    sthController = TextEditingController();
  }

  @override
  void dispose() {
    regionController.dispose();
    provinceController.dispose();
    cityController.dispose();
    barangayController.dispose();
    sthController.dispose();
    super.dispose();
  }

  bool _areFieldsFilled() {
    return regionController.text.trim().isNotEmpty &&
        provinceController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        barangayController.text.trim().isNotEmpty &&
        sthController.text.trim().isNotEmpty;
  }

  void _handleCheckbox(bool? newValue) {
    setState(() {
      _isChecked = newValue ?? false;
      if (_isChecked) {
        regionController.text = widget.data.region ?? '';
        provinceController.text = widget.data.province ?? '';
        cityController.text = widget.data.city ?? '';
        barangayController.text = widget.data.brgy ?? '';
        sthController.text = widget.data.streetHouseBuilding ?? '';
      } else {
        regionController.clear();
        provinceController.clear();
        cityController.clear();
        barangayController.clear();
        sthController.clear();
      }
    });
  }

  void _showAlert(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _createAccountAndSaveToFirebase() async {
    try {
      // ✅ Create Firebase Auth account
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.data.email!.trim(),
            password: widget.data.password!,
          );

      final uid = credential.user?.uid;
      if (uid == null) throw Exception("User ID is null");

      // ✅ Upload images to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child("users/$uid");
      String? selfieUrl;
      String? idUrl;

      if (widget.data.selfiePath != null &&
          widget.data.selfiePath!.isNotEmpty) {
        final file = File(widget.data.selfiePath!);
        if (file.existsSync()) {
          final selfieRef = storageRef.child("selfie.jpg");
          await selfieRef.putFile(file);
          selfieUrl = await selfieRef.getDownloadURL();
        }
      }

      if (widget.data.idPath != null && widget.data.idPath!.isNotEmpty) {
        final file = File(widget.data.idPath!);
        if (file.existsSync()) {
          final idRef = storageRef.child("id.jpg");
          await idRef.putFile(file);
          idUrl = await idRef.getDownloadURL();
        }
      }

      // ✅ Save user data to Firestore
      await FirebaseFirestore.instance.collection("Users").doc(uid).set({
        "uid": uid,
        "firstName": widget.data.firstName,
        "lastName": widget.data.lastName,
        "email": widget.data.email,
        "phoneNumber": widget.data.phoneNumber,
        "birthday":
            widget.data.birthday?.toIso8601String().split("T").first ?? "",
        "gender": widget.data.gender,
        "region": widget.data.region,
        "province": widget.data.province,
        "city": widget.data.city,
        "brgy": widget.data.brgy,
        "streetHouseBuilding": widget.data.streetHouseBuilding,
        "fullAddress": widget.data.fullAddress,
        "residenceAddress": widget.data.residenceAddress,
        "selfieUrl": selfieUrl,
        "idUrl": idUrl,
        "status": widget.data.status ?? "pending",
        "roles": "user",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // ✅ Navigate directly to Verification Page
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VerificationPage()),
        (route) => false,
      );

      ToastHelper.showSuccess(context, "Account successfully created!");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showAlert(e.message ?? "Authentication error");
    } catch (e) {
      if (!mounted) return;
      _showAlert("Unexpected error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSubmit() async {
    if (!_areFieldsFilled()) {
      _showAlert("Please complete all address fields before submitting.");
      return;
    }

    setState(() => _isLoading = true);

    widget.data.region = regionController.text.trim();
    widget.data.province = provinceController.text.trim();
    widget.data.city = cityController.text.trim();
    widget.data.brgy = barangayController.text.trim();
    widget.data.streetHouseBuilding = sthController.text.trim();

    widget.data.residenceAddress = [
      sthController.text.trim(),
      barangayController.text.trim(),
      cityController.text.trim(),
      provinceController.text.trim(),
      regionController.text.trim(),
    ].where((e) => e.isNotEmpty).join(', ');

    await _createAccountAndSaveToFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                Text(
                  "What is your Residence?",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Kindly provide your actual residence address",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                _buildLabel("Region"),
                const SizedBox(height: 10),
                CustomTextinput(regionController, "Select Region", false),
                const SizedBox(height: 16),

                if (isNarrow) ...[
                  _buildLabel("Province"),
                  const SizedBox(height: 10),
                  CustomTextinput(provinceController, "Select Province", false),
                  const SizedBox(height: 16),
                  _buildLabel("City"),
                  const SizedBox(height: 10),
                  CustomTextinput(cityController, "Select City", false),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: _buildLabel("Province", leftPadding: 0)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildLabel("City", leftPadding: 0)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextinput(
                          provinceController,
                          "Select Province",
                          false,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: CustomTextinput(
                          cityController,
                          "Select City",
                          false,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                _buildLabel("Barangay"),
                const SizedBox(height: 10),
                CustomTextinput(barangayController, "Barangay", false),
                const SizedBox(height: 16),

                _buildLabel("Street / House No. / Building"),
                const SizedBox(height: 10),
                CustomTextinput(
                  sthController,
                  "House No / Building / Street / Village / Subd.",
                  false,
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: _handleCheckbox,
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                            ? const Color.fromARGB(255, 6, 37, 53)
                            : Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          "Same as the submitted ID address",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 1, 47, 72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 6, 37, 53),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Create Account",
                            style: GoogleFonts.inter(
                              fontSize: 16,
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
      },
    );
  }

  Widget _buildLabel(String text, {double leftPadding = 20}) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const Text(
            " *",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
