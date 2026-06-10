import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstOnboarding extends StatelessWidget {
  const FirstOnboarding({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 223,
              height: 180,
            ),
            Text(
              "AGAPAY",
              style: GoogleFonts.poppins(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "Search & Response",
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black
              ),
            )
          ],
        ),
      ),
    );
  }
}
