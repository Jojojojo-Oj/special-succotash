import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecondOnboarding extends StatelessWidget {
  const SecondOnboarding({super.key, required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Welcome to",
              style: GoogleFonts.poppins(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),             
            ),
            Text(
              "AGAPAY",
              style: GoogleFonts.poppins(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),
            ),
            SizedBox(height: 35,),
            Image.asset('assets/images/onb.png'),
            SizedBox(
              width: 330,
              child: Text(
                "Your lifeline during emergencies. AGAPAY connects you to help — fast, secure, and reliable.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 35,),
            SizedBox(
              width: 332,
              height: 65,
              child: OutlinedButton(
                onPressed: (){
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                }, 
                style: OutlinedButton.styleFrom(backgroundColor: Color.fromARGB(255, 6, 37, 53)),
                child: Text("Get Started", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),)),
            ),
                      
          ],
        ),
      ),
    );
  }
}