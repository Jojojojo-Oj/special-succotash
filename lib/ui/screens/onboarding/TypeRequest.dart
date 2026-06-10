import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FourthOnboarding extends StatelessWidget {
  const FourthOnboarding({super.key, required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Types of Help You Can",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),             
            ),
            Text(
              "Request",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),
            ),
            SizedBox(height: 40,),
            Image.asset('assets/images/onb4.png'),
            SizedBox(
              width: 330,
              child: Text(
                "Choose the type of emergency so we send the right responders.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30,),
            SizedBox(
              width: 300,
              child: Text(
                "• Tap your situation",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: 300,
              child: Text(
                "• Upload an image",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: 300,
              child: Text(
                "• Rescuers are dispatched right away",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 35,),
            SizedBox(
              width: 332,
              height: 65,
              child: OutlinedButton(
                onPressed: (){
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                }, 
                style: OutlinedButton.styleFrom(backgroundColor: Color.fromARGB(255, 6, 37, 53)),
                child: Text("I understand", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),)),
            ),
            
                      
          ],
        ),
      ),
    );
  }
}