import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20page/bhc_page.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/facilities_card.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20page/firestation_page.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20page/hospital_page.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20page/police_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Facilities extends StatelessWidget {
  const Facilities({super.key});

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
        title: Text("Emergency Facilities", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),

      ),

      //BODY
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("For you Information", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.left,),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 5, left: 10),
              child: Text("Find nearby emergency facilities such as police, fire, and medical stations across Caloocan City South. These centers are ready to provide quick response and vital assistance in times of need. ", 
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey), 
              textAlign: TextAlign.left,),
            ),

            Padding(
              padding: EdgeInsetsGeometry.only(top: 20, left: 10),
              child: Text("Stations", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.left,),
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: FacilitiesCard(
                imagePath: "assets/images/police_icon.svg", 
                title: "Police Station", 
                descript: "Handles safety, security, and emergency response to protect residents within the community.",
                onTap: (){   
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => PolicePage()));             
                },
                )
              ),
            
            
             Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: FacilitiesCard(
                imagePath: "assets/images/firestation_icon.svg", 
                title: "Fire Station", 
                descript: "Equipped with trained firefighters and emergency vehicles to respond to fires, rescues, and other urgent situations.",
                onTap: (){     
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => FirestationPage()));           
                },
                )
              ),
            
             Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: FacilitiesCard(
                imagePath: "assets/images/hospital_icon.svg", 
                title: "Hospital", 
                descript: "Provides immediate medical attention and specialized treatment for patients in critical or emergency conditions.",
                onTap: (){      
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => HospitalPage()));          
                },
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: FacilitiesCard(
                imagePath: "assets/images/bgh_icon.svg", 
                title: "Barangay Health Center", 
                descript: "Offers primary healthcare, medical consultations, and basic services for residents at the barangay level.",
                onTap: (){        
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => BhcPage()));        
                },
                )
            ),

              

          ],
        ),
        ),
    );

  }
}