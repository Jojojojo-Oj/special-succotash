import 'package:agapay_users/ui/screens/auth/login/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SixthOnboarding extends StatelessWidget {
  const SixthOnboarding({super.key,required this.controller});
  final PageController controller;



  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Allow Notification",
              style: GoogleFonts.poppins(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),             
            ),
            SizedBox(height: 20,),
            Image.asset('assets/images/onb5.png'),
            SizedBox(height: 40,),
            SizedBox(
              width: 330,
              child: Text(
                "Stay informed with real-time updates, schedule reminders, and important alerts by enabling notifications.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 5, 26, 9)
                ),
                textAlign: TextAlign.center,
              ),          
            ),
            SizedBox(height: 100,),
            SizedBox(
              width: 332,
              height: 65,
              child: OutlinedButton(
                onPressed: (){
                  _completeOnboarding(context);
                }, 
                style: OutlinedButton.styleFrom(backgroundColor: Color.fromARGB(255, 6, 37, 53)),
                child: Text("Allow Notification", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),)
                ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: (){},
              child: Text("Not Now", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),),
            )
                      
          ],
        ),
      ),
    );
  }
}