import 'package:agapay_users/ui/screens/HOMEPAGE/control_page.dart';
import 'package:agapay_users/ui/screens/auth/auth-service.dart';
import 'package:agapay_users/ui/screens/auth/registration/address_panel.dart';
import 'package:agapay_users/ui/screens/auth/registration/bday_panel.dart';
import 'package:agapay_users/ui/screens/auth/registration/createpass_panel.dart';
import 'package:agapay_users/ui/screens/auth/registration/details_panel.dart';
import 'package:agapay_users/ui/screens/auth/registration/gender_panel.dart';
import 'package:agapay_users/ui/screens/auth/registration/idphoto_panel.dart';
import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:agapay_users/ui/screens/auth/registration/residence_panel.dart';
import 'package:agapay_users/ui/screens/auth/registration/selfie_panel.dart';
import 'package:agapay_users/ui/screens/auth/verification/verification_page.dart';
import 'package:agapay_users/ui/screens/loading/loading_page.dart';
import 'package:agapay_users/ui/widgets/TextFieldWidget.dart';
import 'package:agapay_users/utils/toast_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final PageController _pageController = PageController();
  final PanelController _panelController = PanelController();
  final RegistrationData registrationData = RegistrationData();

  bool _isLoading = false;
  late TextEditingController _username;
  late TextEditingController _password;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  // ✅ Fixed LOGIN FUNCTION with mounted checks
 Future<void> _login() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final user = await _authService.signInWithEmail(
      email: _username.text.trim(),
      password: _password.text.trim(),
    );

    if (user == null) {
      if (mounted) ToastHelper.showError(context, "Login failed");
      return;
    }

    final docRef = FirebaseFirestore.instance.collection("Users").doc(user.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      if (mounted) ToastHelper.showError(context, "User data not found in Firestore");
      return;
    }

    final userData = docSnapshot.data();
    final status = userData?["status"] ?? "pending";
    debugPrint("🟢 User status: $status");

    if (!mounted) return;

    if (status == "pending") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerificationPage()),
      );
    } else if (status == "approved") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
      if (mounted) ToastHelper.showSuccess(context, "Login successful!");
    } else if (status == "rejected") {
      ToastHelper.showError(context, "Your account was rejected");
    } else {
      ToastHelper.showError(context, "Unknown account status");
    }
  } catch (e) {
    debugPrint("🔥 Login error: $e");
    if (mounted) ToastHelper.showError(context, e.toString());
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingPage();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(1, 47, 72, 1),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Log In Account",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Discover your social & Try to Login",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Image.asset("assets/images/logo.png", width: 150),
                    const SizedBox(height: 10),
                    Text(
                      "AGAPAY",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(1, 47, 72, 1),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 330,
                      child: CustomTextinput(_username, "Enter Email", false),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 330,
                      child: CustomTextinput(_password, "Enter Password", true),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 330,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 6, 37, 53),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (!_panelController.isPanelOpen) {
                              _panelController.open();
                            }
                          },
                          child: Text(
                            "Sign up",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(1, 47, 72, 1),
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

          // 🔽 Sliding registration panel
          SlidingUpPanel(
            controller: _panelController,
            backdropEnabled: true,
            backdropOpacity: 0.3,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            color: Colors.white,
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
            onPanelClosed: () {
              setState(() => currentPage = 0);
              _pageController.jumpToPage(0);
            },
            panelBuilder: (sc) => _buildPanelContent(sc),
          ),
        ],
      ),
    );
  }

  // 🧩 Registration panels
  Widget _buildPanelContent(ScrollController sc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 50,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            children: [
              PanelContent(controller: _pageController, data: registrationData),
              BdayPanel(controller: _pageController, data: registrationData),
              GenderPanel(controller: _pageController, data: registrationData),
              CreatepassPanel(controller: _pageController, data: registrationData),
              SelfiePanel(controller: _pageController, data: registrationData),
              VerifyIDPanel(controller: _pageController, data: registrationData),
              AddressPanel(controller: _pageController, data: registrationData),
              ResidencePanel(controller: _pageController, data: registrationData),
            ],
          ),
        ),
        SmoothPageIndicator(
          controller: _pageController,
          count: 8,
          effect: ExpandingDotsEffect(
            activeDotColor: const Color.fromARGB(255, 6, 37, 53),
            dotColor: Colors.grey.shade300,
            dotHeight: 10,
            dotWidth: 10,
            spacing: 8,
            expansionFactor: 3,
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
