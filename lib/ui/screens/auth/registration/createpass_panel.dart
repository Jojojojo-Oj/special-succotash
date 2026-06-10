import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:agapay_users/ui/widgets/TextFieldWidget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatepassPanel extends StatefulWidget {
  const CreatepassPanel({
    super.key,
    required this.controller,
    required this.data,
  });

  final PageController controller;
  final RegistrationData data;

  @override
  State<CreatepassPanel> createState() => _CreatepassPanelState();
}

class _CreatepassPanelState extends State<CreatepassPanel> {
  late TextEditingController passController;
  late TextEditingController repassController;

  bool isButtonEnabled = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    passController = TextEditingController();
    repassController = TextEditingController();

    passController.addListener(_validateInputs);
    repassController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final password = passController.text.trim();
    final rePassword = repassController.text.trim();

    String? error;

    if (password.isEmpty || rePassword.isEmpty) {
      error = "Password cannot be empty";
    } else if (password.length < 8) {
      error = "Password must be at least 8 characters";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      error = "Password must contain at least one uppercase letter";
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      error = "Password must contain at least one lowercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      error = "Password must contain at least one number";
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      error = "Password must contain at least one special character";
    } else if (password != rePassword) {
      error = "Passwords do not match";
    }

    final shouldEnable =
        password.isNotEmpty && rePassword.isNotEmpty && error == null;

    if (shouldEnable != isButtonEnabled || error != errorMessage) {
      setState(() {
        isButtonEnabled = shouldEnable;
        errorMessage = error;
      });
    }
  }

  @override
  void dispose() {
    passController.dispose();
    repassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Text(
            "Create password",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Set a secure password to protect your account. Use at least 8 characters, including numbers and symbols.",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.grey,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 30),

          // Create password field
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "Create password",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                " *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 340,
            child: CustomTextinput(passController, "Password", true),
          ),

          const SizedBox(height: 20),

          // Retype password field
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "Retype Password",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                " *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 340,
            child: CustomTextinput(repassController, "Retype Password", true),
          ),

          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                errorMessage!,
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),

          const Spacer(),

          // Next button
          SizedBox(
            width: 340,
            height: 65,
            child: OutlinedButton(
              onPressed: isButtonEnabled
                  ? () {
                      widget.data.password = passController.text.trim();
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
