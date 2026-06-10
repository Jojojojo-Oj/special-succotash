import 'package:agapay_users/ui/screens/homepage/services/evacuation/evacuationCenter_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EvacutionList extends StatelessWidget {
  const EvacutionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //APP BAR
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(1, 47, 72, 1),
        toolbarHeight: 80,
        title: Text("Evacuation List", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
      ),
      
      //BODY
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Evacuation Center", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.left,),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20, left: 10),
              child: Text("Find nearby evacuation sites thoughtfully arranged to help communities prepare for and respond efficiently to emergencies.", 
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey), 
              textAlign: TextAlign.left,),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(top: 10, bottom: 20,),
              child: EvacuationCenterCard(),
              ),
            
            Padding(
              padding: EdgeInsetsGeometry.only(top: 10, bottom: 20,),
              child: EvacuationCenterCard(),
              ),

            Padding(
              padding: EdgeInsetsGeometry.only(top: 10, bottom: 20,),
              child: EvacuationCenterCard(),
              ),

            Padding(
              padding: EdgeInsetsGeometry.only(top: 10, bottom: 20,),
              child: EvacuationCenterCard(),
              ),
            
            Padding(
              padding: EdgeInsetsGeometry.only(top: 10, bottom: 20,),
              child: EvacuationCenterCard(),
              ),
            Padding(
              padding: EdgeInsetsGeometry.only(top: 10, bottom: 20,),
              child: EvacuationCenterCard(),
              ),
            Padding(
              padding: EdgeInsetsGeometry.only(top: 10, bottom: 20,),
              child: EvacuationCenterCard(),
              ),
          ],
        ),
        ),
    );
  }
}