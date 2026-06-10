// import 'package:agapay_users/ui/screens/auth/login/user_login.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SelectLogin extends StatelessWidget {
//   const SelectLogin({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: EdgeInsetsGeometry.only(left: 20, right: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
              
//               Image.asset("assets/images/logo.png",width: 100,),

//               Padding(padding: EdgeInsets.only(top: 30, left: 20,right: 20,bottom: 20),
//               child: Text("Select Your Account Type", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24,color: Color.fromRGBO(21, 34, 79, 1)),textAlign: TextAlign.center,),             
//               ),

//               GestureDetector(
//                 onTap: (){
//                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   padding: const EdgeInsets.all(20),
//                   decoration:  BoxDecoration(
//                     color: const Color(0xFF0C2D57),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4)
//                       )
//                     ]
//                   ),
//                   child: Row(
//                     children: [
//                       Image.asset("assets/images/uuu.png", width: 150,),
//                       const SizedBox(width: 5),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("USER", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
//                             Text("Request Rescue, report emergencies, and get updates", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal , color: Colors.white),),
//                           ],
//                         )
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               SizedBox(height: 10,),

//               GestureDetector(
//                 onTap: (){
//                   debugPrint("Rescuer");
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   padding: const EdgeInsets.all(20),
//                   decoration:  BoxDecoration(
//                     color: const Color(0xFFCE352A),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4)
//                       )
//                     ]
//                   ),
//                   child: Row(
//                     children: [
//                       Image.asset("assets/images/rescuers.png", width: 150,),
//                       const SizedBox(width: 5),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("RESCUER", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
//                             Text("Respond to SOS alerts and guide victims to safety", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal , color: Colors.white),),
//                           ],
//                         )
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20,),
//               Text("Choose your role to continue.", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),)
            
              

//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
