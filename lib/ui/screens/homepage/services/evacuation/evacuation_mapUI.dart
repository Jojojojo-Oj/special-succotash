import 'package:agapay_users/ui/screens/homepage/services/evacuation/evacmap.dart';
import 'package:agapay_users/ui/screens/homepage/services/evacuation/shelter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EvacutionMapUI extends StatelessWidget {
  EvacutionMapUI({super.key});

  final List<Shelter> shelters = [
  Shelter(name: "Barangay 4 Daycare Center", address: "Main St, City"),
  Shelter(name: "Barangay 4 Community Covered Court ", address: "2nd Ave, Town"),
  Shelter(name: "Barangay 12 Shell House", address: "Barangay Hall"),
  Shelter(name: "Barangay 14 Kaunlaran Village M. B. Asistio Sr. High School", address: "Coastal Area"),
  Shelter(name: "Barangay 14 Kaunlaran Elementary School", address: "123 Street"),
  Shelter(name: "Barangay 17 & 19 Dagat-Dagatan Caloocan Central Elementary School", address: "123 Street"),
  Shelter(name: "Barangay 17 & 19 Dagat-Dagatan Caloocan Central Covered Court", address: "123 Street"),
  Shelter(name: "Barangay 20 Kaunlaran Elementary School", address: "123 Street"),
  Shelter(name: "Barangay 20 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 24 Sampalukan Elementary School", address: "123 Street"),
  Shelter(name: "Barangay 24 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 28 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 28 Kasarinlan Elementary School", address: "123 Street"),
  Shelter(name: "Barangay 28 Kasarinlan High School", address: "123 Street"),
  Shelter(name: "Barangay 29 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 33 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 34 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 35 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 36 Barrio Obrero Elementary School", address: "123 Street"),
  Shelter(name: "Barangay 36 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 52 Grace Park Elementary School (Main)", address: "123 Street"),
  Shelter(name: "Barangay 52 Caloocan High School", address: "123 Street"),
  Shelter(name: "Barangay 56 Barangay Hall", address: "123 Street"),
  Shelter(name: "Barangay 62 Grace Park Elementary School Annex", address: "123 Street"),
  Shelter(name: "Barangay 63 Barangay Hall / Multipurpose Center", address: "123 Street"),
  Shelter(name: "Barangay 63 Maria Clara High School", address: "123 Street"),
 
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //APP BAR
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(1, 47, 72, 1),
        toolbarHeight: 80,
        title: Text("Evacuation map", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
      ),
      
      //BODY
      body: Stack(
        children: [
          EvacuationMap(),
          
           Align(
            alignment: Alignment.bottomCenter,
            child: ShelterBottomPanel(
              shelters: shelters,
              onTap: (shelter) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Tapped: ${shelter.name}",),
                  duration: const Duration(milliseconds: 500),),
                );

                
              },
            ),
          ),
        ],
      )
      
    );
  }
}