import 'package:agapay_users/ui/screens/homepage/services/evacuation/card.dart';
import 'package:agapay_users/ui/screens/homepage/services/evacuation/evacuation_mapUI.dart';
import 'package:agapay_users/ui/screens/homepage/services/evacuation/evacution_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EvacuationUi extends StatelessWidget {
  const EvacuationUi({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.light, 
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(

      backgroundColor: Colors.white,
      //APPBAR
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(1, 47, 72, 1),
        toolbarHeight: 80,
        title: Text("Evacuation Facility", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
      ),


      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("For you Information", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.left,),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20, left: 10),
              child: Text("Evacuation Centers serve as designated safe zones that provide temporary shelter, relief, and assistance to affected individuals and families during emergencies and calamities. ", 
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey), 
              textAlign: TextAlign.left,),
            ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20,),
              child: EvacuationCard(
                imagePath: "assets/images/evac_map_icon.png", 
                title: "Evacuation Map", 
                descript: "View safe evacuation sites near you and across Caloocan South using this map.",
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => EvacutionMapUI()));
                },)
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20,),
              child: EvacuationCard(
                imagePath: "assets/images/evac_list_icon.png", 
                title: "Evacuation List", 
                descript: "Stay safe and informed. Here are trusted evacuation shelters across Caloocan City South where you and your family can go during emergencies and disasters.",
                onTap: (){
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => EvacutionList())
                  );
                },)
              ),
          ],
        )
      ),
    );
  }
}