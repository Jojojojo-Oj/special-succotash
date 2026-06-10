import 'package:agapay_users/ui/screens/homepage/services/facilities/facilities_card.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20maps/police_map.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/station%20page/station_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PolicePage extends StatelessWidget {
  const PolicePage({super.key});

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
                    MaterialPageRoute(builder: (context) => PoliceMap()));                                       
                },
                )
              ),
            
            Padding(
              padding: EdgeInsetsGeometry.only(top: 20, left: 10),
              child: Text("Police Stations", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.left,),
              ),
            

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Caloocan City Police Station", 
                descript: "31 Tuna St, Maypajo, Caloocan, 1400 Metro Manila",               
                )
              ),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Northern Police District Office", 
                descript: "7025 Dagat-Dagatan Ave, Poblacion, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Caloocan City Police Station (Main / South Headquarters)", 
                descript: "Samson Road, Barangay 80, Sangandaan, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Police Station 1", 
                descript: "Samson Rd, Sangandaan, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Police- Sub Station 1", 
                descript: "Malolos Ave, Bagong Barrio West, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Police- Sub Station 2", 
                descript: "C3 Road, 8th Street, de Jesus, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Police- Sub Station 3", 
                descript: "9th Avenue corner A. Del Mundo Street, Grace Park, Caloocan City",               
                )
              ),
            
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10,),
              child: StationCard(
                imagePath: "assets/images/officer_icon.svg", 
                title: "Police- Sub Station 4", 
                descript: "General San Miguel St, Sangandaan, Caloocan City",               
                )
              ),
            
            
            
          ]
        )
      ),

    );
  }
}