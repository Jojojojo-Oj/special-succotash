import 'package:agapay_users/ui/screens/homepage/services/eco%20bag/gobagitem.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class ReEcoBag extends StatefulWidget {
  const ReEcoBag({super.key});

  @override
  State<ReEcoBag> createState() => _ReEcoBagState();
}

class _ReEcoBagState extends State<ReEcoBag> {
   final PageController _pageController = PageController();
   int _currentPage = 0;



  @override
  Widget build(BuildContext context) {

    return Scaffold(  
      backgroundColor: Colors.white,
      //APP BAR
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 30, color: Color(0xFF33434F),) 
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        toolbarHeight: 50,       
      ),

      //BODY
      body: Center(
        child: Column(
          children: [
            Text("EMERGENCY", style: GoogleFonts.poppins(color: Color(0xFF217F48), fontWeight: FontWeight.w900,fontSize: 59,letterSpacing: 2,
            shadows: [Shadow(color: Colors.black.withOpacity(0.25),
            offset: const Offset(1.5, 2.5),
            blurRadius: 3          
            )]),
            textAlign: TextAlign.center,
            ),
            Container(          
              width: double.infinity,
              color: Color(0xFFF36523),
              child: Center(
                child: Text("GO BAG", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 60,letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1.5, 2.5),
                    blurRadius: 3
                  )
                ] ),
                ),
              )
            ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/go.png",width: 100,height: 100,),
                  SizedBox(width: 20,),
                  SizedBox(
                    width: 230,
                    child: Text("Ang mga nilalaman ng\nGo Bag",style: GoogleFonts.poppins(fontWeight: FontWeight.w800,fontSize: 30,color: Colors.black,height: 1), textAlign: TextAlign.center,),
                  )
                ],
              ),
            ),

            SizedBox(height: 15,),
               Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildGoBagPage1(),
                    _buildGoBagPage2()
                  ],
                )
              ),
            
            SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: const WormEffect(
                    activeDotColor: Color(0xFF33434F),
                    dotColor: Colors.black26,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 20,
                    paintStyle: PaintingStyle.fill,
                  ),
                ),
              
              SizedBox(height: 50,)
              


          ],
        ),
      ),
    );
  }
}


Widget _buildGoBagPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 25,
        children: const [
          GoBagItem(
            imagePath: 'assets/images/papel.png',
            label: 'Mahalagang Dokumento\nilagay sa selyadong lagayan',
          ),
          GoBagItem(
            imagePath: 'assets/images/pera.png',
            label: 'Pera at Barya',
          ),
          GoBagItem(
            imagePath: 'assets/images/pito.png',
            label: 'Flashlight, Kandila,\nPosporo at Silbato/\nWhistle',
          ),
          GoBagItem(
            imagePath: 'assets/images/radyo.png',
            label: 'Radyo at Extra Bateriya',
          ),
          GoBagItem(imagePath: 'assets/images/aid.png', label: 'First Aid Kit'),
          GoBagItem(
            imagePath: 'assets/images/pagkain.png',
            label: 'Pagkain at Inumin',
          ),
        ],
      ),
    );
  }

  // 🧱 PAGE 2 — Second Swipe Page (matches your image)
  Widget _buildGoBagPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 25,
        runSpacing: 25,
        children: const [
          GoBagItem(
            imagePath: 'assets/images/cp.png',
            label: 'Cellphone, Charger,\nat Powerbank',
          ),
          GoBagItem(
            imagePath: 'assets/images/damit.png',
            label: 'Damit, Kapote, Bota,\nat Sanitary Supplies',
          ),
          GoBagItem(
            imagePath: 'assets/images/kumot.png',
            label: 'Sleeping bag at Kumot',
          ),
        ],
      ),
    );
  }