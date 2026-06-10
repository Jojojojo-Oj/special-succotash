import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:agapay_users/ui/widgets/form_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agapay_users/ui/widgets/TextFieldWidget.dart';

class PanelContent extends StatefulWidget {
  const PanelContent({super.key, required this.controller, required this.data});
  final PageController controller;
  final RegistrationData data;

  @override
  State<PanelContent> createState() => _PanelContentState();
}

class _PanelContentState extends State<PanelContent> {
  late TextEditingController fnameController;
  late TextEditingController lnameController;
  late TextEditingController emailController;
  late TextEditingController pnumberController;

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    fnameController = TextEditingController();
    lnameController = TextEditingController();
    emailController = TextEditingController();
    pnumberController = TextEditingController();

    fnameController.addListener(_validateForm);
    lnameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    pnumberController.addListener(_validateForm);
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    emailController.dispose();
    pnumberController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    // Extract only digits after +63
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    // Should be 63 + 10 digits = 12 total digits
    return digits.length == 12 && digits.startsWith('63');
  }

  void _validateForm() {
    final shouldEnable = fnameController.text.trim().isNotEmpty &&
        lnameController.text.trim().isNotEmpty &&
        _isValidEmail(emailController.text.trim()) &&
        _isValidPhoneNumber(pnumberController.text);

    if (shouldEnable != isButtonEnabled) {
      setState(() {
        isButtonEnabled = shouldEnable;
      });
    }
  }

  final _phoneFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      // Extract only digits from the new input
      String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

      // Remove country code if user typed it
      if (digits.startsWith('63')) {
        digits = digits.substring(2);
      } else if (digits.startsWith('0')) {
        digits = digits.substring(1);
      }

      // Limit to 10 digits (Philippine mobile number without country code)
      if (digits.length > 10) {
        digits = digits.substring(0, 10);
      }

      // Build formatted string: +63 9XX XXX XXXX
      final buffer = StringBuffer('+63');
      for (int i = 0; i < digits.length; i++) {
        if (i == 0 || i == 3 || i == 6) buffer.write(' ');
        buffer.write(digits[i]);
      }

      final formatted = buffer.toString();

      // Calculate cursor position - always at the end for simplicity and stability
      // This prevents glitches when editing in the middle
      int cursorPos = formatted.length;

      // If user is trying to position cursor before +63, keep it after
      if (newValue.selection.baseOffset < 3) {
        cursorPos = formatted.length > 3 ? 4 : 3;
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: cursorPos.clamp(3, formatted.length)),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Text("Create Account",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 24)),
            const SizedBox(height: 10),
            Text(
              "Create your account to stay connected during disasters.",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            const FormLabel(text: "First Name"),
            const SizedBox(height: 10),
            SizedBox(
              width: 340,
              child: CustomTextinput(fnameController, "First Name", false),
            ),

            const SizedBox(height: 10),
            const FormLabel(text: "Last Name"),
            const SizedBox(height: 10),
            SizedBox(
              width: 340,
              child: CustomTextinput(lnameController, "Last Name", false),
            ),

            const SizedBox(height: 10),
            const FormLabel(text: "Email Address"),
            const SizedBox(height: 10),
            SizedBox(
              width: 340,
              child: CustomTextinput(emailController, "Email Address", false),
            ),

            const SizedBox(height: 10),
            const FormLabel(text: "Phone Number"),
            const SizedBox(height: 10),
            SizedBox(
              width: 340,
              child: TextField(
                controller: pnumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [_phoneFormatter],
                decoration: InputDecoration(
                  hintText: "+63 912 345 6789",
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 15),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 340,
              height: 65,
              child: OutlinedButton(
                onPressed: isButtonEnabled
                    ? () {
                        // Save data before moving forward
                        widget.data.firstName = fnameController.text.trim();
                        widget.data.lastName = lnameController.text.trim();
                        widget.data.email = emailController.text.trim();
                        // Store phone with digits only for consistency
                        widget.data.phoneNumber = pnumberController.text
                            .replaceAll(RegExp(r'\s'), ''); // +639XXXXXXXXX format

                        widget.controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isButtonEnabled
                      ? const Color.fromARGB(255, 6, 37, 53)
                      : Colors.grey[400],
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
          ],
        ),
      ),
    );
  }
}
