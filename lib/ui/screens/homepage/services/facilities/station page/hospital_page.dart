import 'package:agapay_users/ui/screens/homepage/services/facilities/facilities_card.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/hospital_map.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20page/station_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HospitalPage extends StatelessWidget {
  const HospitalPage({super.key});

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
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: FacilitiesCard(
                imagePath: "assets/images/gv_icon.svg", 
                title: "General View", 
                descript: "View your location and find the closest emergency service centers for faster response and safety.",
                onTap: (){      
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => HospitalMap()));                                         
                },
                )
              ),
            
            Padding(
              padding: EdgeInsetsGeometry.only(top: 20, left: 10),
              child: Text("Hospital Stations", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.left,),
              ),
            
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/doctor_icon.svg", 
                title: "Caloocan City Medical Center (South)", 
                descript: "450 A. Mabini St, Poblacion, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/doctor_icon.svg", 
                title: "Martinez Memorial Hospital, Inc.", 
                descript: "198 A. Mabini Street, Maypajo, Caloocan City,",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/doctor_icon.svg", 
                title: "Our Lady of Grace Hospital", 
                descript: "8th Avenue cor. F. Roxas St., Grace Park, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/doctor_icon.svg", 
                title: "Manila Central University Hospital", 
                descript: "MCU Hospital, Morning Breeze Subdivision, Caloocan City",               
                )
              ),
            
            
          ]
        )
      ),

    );
  }
}