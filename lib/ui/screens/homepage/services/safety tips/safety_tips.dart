import 'package:agapay_users/ui/screens/homepage/services/safety%20tips/info_earthquake.dart';
import 'package:agapay_users/ui/screens/homepage/services/safety%20tips/info_fire.dart';
import 'package:agapay_users/ui/screens/homepage/services/safety%20tips/info_typhoon.dart';
import 'package:agapay_users/ui/screens/homepage/services/safety%20tips/safetyCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyTips extends StatelessWidget {
  const SafetyTips({super.key});

  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.light, 
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(

      //APPBAR
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(1, 47, 72, 1),
        toolbarHeight: 80,
        title: Text("Safety Tips", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),),
      ),

      //BODY CONTENT

      body: Padding(
            padding: const EdgeInsets.only(top: 70), 
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    SafetyCardButton(
                      imagePath: 'assets/images/typhoon.gif',
                      title: 'TYPHOON',
                      overlay: Colors.black.withValues(alpha: 0.4),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => InfoTyphoonPage()));
                      },
                    ),
                    const SizedBox(height: 35),
                    SafetyCardButton(
                      imagePath: 'assets/images/earthquake.gif',
                      title: 'EARTHQUAKE',
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFA85F27).withValues(alpha: 0.7),
                          const Color(0xFF593700).withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => InfoEarthquakePage()));
                      },
                    ),
                    const SizedBox(height: 35),
                    SafetyCardButton(
                      imagePath: 'assets/images/fire.gif',
                      title: 'FIRE',
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF512F).withValues(alpha: 0.3),
                          const Color.fromARGB(255, 223, 47, 16)
                              .withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => InfoFirePage()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),



    );
  }
}