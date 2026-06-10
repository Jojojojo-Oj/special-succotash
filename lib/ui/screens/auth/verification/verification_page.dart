import 'package:agapay_users/ui/screens/auth/auth-service.dart';
import 'package:agapay_users/ui/screens/auth/login/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationPage extends StatefulWidget {
  
  const VerificationPage({super.key});

  
  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final AuthService _authService = AuthService();

  Future<void> signOut() async {
  await _authService.signOut();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        
        leading: IconButton(
          padding: EdgeInsets.only(left: 20),
          onPressed: (){
            signOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
          }, 
          icon: Icon(Icons.arrow_back,size: 40,)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [                 
            Text(
              "Verification in progress...",
              style: GoogleFonts.poppins(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 5, 26, 9)
              ),             
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 35,),
            Image.asset('assets/images/veri.png'),
            SizedBox(height: 35,),
            SizedBox(
              width: 330,
              child: Text(
                "Hang tight — we’re working on your account. Feel free to come back later.",
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
                }, 
                style: OutlinedButton.styleFrom(backgroundColor: Color.fromARGB(255, 6, 37, 53)),
                child: Text("Refresh", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),)),
            ),
             SizedBox(height: 100,),           
          ],
        ),
      ),
    );
  }
}