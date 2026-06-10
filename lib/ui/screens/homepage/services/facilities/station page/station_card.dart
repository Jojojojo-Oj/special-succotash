import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class StationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String descript;


  const StationCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.descript,
    });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(    
        width: double.infinity,
        height: 130,
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: Color.fromRGBO(231, 245, 252, 1),
          borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), 
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(1, 4), 
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descript,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.start,
                    softWrap: true, 
                  ),
                  
                  SizedBox(height: 10,),

                  // Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Text(
                  //       "View",
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 13,
                  //         fontWeight: FontWeight.w600,
                  //         color: Color.fromRGBO(0, 90, 139, 1)
                  //       ),
                  //     ),
                  //     SizedBox(width: 4,),
                  //     Icon(Icons.chevron_right,
                  //     color:Color.fromRGBO(0, 90, 139, 1),
                  //     size: 18,)
                  //   ],
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
