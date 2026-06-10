import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThirdOnboarding extends StatelessWidget {
  const ThirdOnboarding({super.key, required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Verified for Safety",
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),             
            ),
            SizedBox(height: 35,),
            Image.asset('assets/images/onb3.png'),

            SizedBox(
              width: 330,
              child: Text(
                "Safety matters. Only verified users from South Caloocan City can request help to prevent abuse.",
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
                "• Submit valid ID for verification",
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
                "• Anonymous reports are not allowed",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 100,),
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