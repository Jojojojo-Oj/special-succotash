// import 'package:agapay_users/ui/screens/auth/registration/address_panel.dart';
// import 'package:agapay_users/ui/screens/auth/registration/bday_panel.dart';
// import 'package:agapay_users/ui/screens/auth/registration/createpass_panel.dart';
// import 'package:agapay_users/ui/screens/auth/registration/details_panel.dart';
// import 'package:agapay_users/ui/screens/auth/registration/gender_panel.dart';
// import 'package:agapay_users/ui/screens/auth/registration/idphoto_panel.dart';
// import 'package:agapay_users/ui/screens/auth/registration/residence_panel.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// class SlideUpRegistration extends StatefulWidget {
//   const SlideUpRegistration({super.key});

//   @override
//   State<SlideUpRegistration> createState() => _SlideUpRegistrationState();
// }

// class _SlideUpRegistrationState extends State<SlideUpRegistration> {
//   final PageController _pageeController = PageController();
//   final PanelController _panelController = PanelController();
  
//   int currentPage = 0;
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:  Colors.white,
//       body: Stack(
//         children: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () async {
//                 if (!_panelController.isPanelOpen) {
//                   _panelController.open();
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 "Show Panel",
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
            
//           ),

//            SlidingUpPanel(
//             controller: _panelController,
//             backdropEnabled: true,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//             minHeight: 0, 
//             maxHeight: MediaQuery.of(context).size.height * 0.9,
//             color: Colors.black,
//             boxShadow: const [
//               BoxShadow(blurRadius: 10, color: Colors.black26),
//             ],
//             onPanelClosed: (){
//               setState(() {
//                 currentPage = 0;
//               });
//               _pageeController.jumpToPage(0);
//             },
//             panelBuilder: (ScrollController sc) => _buildPanelContent(sc),
//           ),
//         ],
//       ),
//     );
//   }


//   Widget _buildPanelContent(ScrollController sc) {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       const SizedBox(height: 12),
//       Container(
//         width: 50,
//         height: 6,
//         decoration: BoxDecoration(
//           color: Colors.grey[400],
//           borderRadius: BorderRadius.circular(3),
//         ),
//       ),
//       const SizedBox(height: 16),

  
//       SizedBox(
//         height: MediaQuery.of(context).size.height * 0.9,
//         child: PageView(
//           physics: NeverScrollableScrollPhysics(),
//           controller: _pageeController,
//           onPageChanged: (index) {
//             setState(() => currentPage = index);
//           },
//           children: [
//             PanelContent(controller: _pageeController,),
//             BdayPanel(controller: _pageeController),
//             GenderPanel(controller: _pageeController),
//             CreatepassPanel(controller: _pageeController),
//             VerifyIDPanel(controller: _pageeController),
//             AddressPanel(controller: _pageeController),
//             ResidencePanel(controller: _pageeController),
//           ],
//         ),
//       ),

//       const SizedBox(height: 20),
    
//       SmoothPageIndicator(
//         controller: _pageeController,
//         count: 7,
//         effect: ExpandingDotsEffect(
//           activeDotColor:Color.fromARGB(255, 6, 37, 53),
//           dotColor: Colors.grey.shade300,
//           dotHeight: 10,
//           dotWidth: 10,
//           spacing: 8,
//           expansionFactor: 3,
//         ),
//       ),
      
//     ],
//   );
// }

// }

