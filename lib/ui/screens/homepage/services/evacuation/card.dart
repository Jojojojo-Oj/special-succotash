import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EvacuationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String descript;
  final VoidCallback onTap;


  const EvacuationCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.descript,
    required this.onTap,
    });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(       
        width: double.infinity,
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 60,
              width: 60,
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

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Learn More",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(0, 90, 139, 1)
                        ),
                      ),
                      SizedBox(width: 4,),
                      Icon(Icons.chevron_right,
                      color:Color.fromRGBO(0, 90, 139, 1),
                      size: 18,)
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
