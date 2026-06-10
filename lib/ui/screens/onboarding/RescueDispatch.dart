import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FifthOnboarding extends StatelessWidget {
  const FifthOnboarding({super.key, required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Real-time Rescue",
              style: GoogleFonts.poppins(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),             
            ),
            Text(
              "Dispatch",
              style: GoogleFonts.poppins(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),
            ),
            SizedBox(height: 35,),
            Image.asset('assets/images/onb2.png'),
            SizedBox(height: 25,),
            SizedBox(
              width: 330,
              child: Text(
                "Send an SOS with just a few taps. AGAPAY alerts the nearest rescue team instantly.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 50,), 
            SizedBox(
              width: 332,
              height: 65,
              child: OutlinedButton(
                onPressed: (){
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                }, 
                style: OutlinedButton.styleFrom(backgroundColor: Color.fromARGB(255, 6, 37, 53)),
                child: Text("Allow Permission", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),)),
            ),
                      
          ],
        ),
      ),
    );
  }
}