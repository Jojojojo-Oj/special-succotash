import 'package:agapay_users/ui/screens/homepage/updates/announcement/announcement_screen.dart';
import 'package:agapay_users/ui/screens/homepage/updates/community/community_screen.dart';
import 'package:agapay_users/ui/screens/homepage/updates/news/news_screen.dart';
import 'package:agapay_users/ui/screens/homepage/updates/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:segmented_button_slide/segmented_button_slide.dart';

class SegmentedButtonDemo extends StatefulWidget {
  const SegmentedButtonDemo({super.key});

  @override
  State<SegmentedButtonDemo> createState() => _SegmentedButtonDemoState();
}

class _SegmentedButtonDemoState extends State<SegmentedButtonDemo> {
  int _selected = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    NewsScreen(),
    CommunityScreen(),
    AnnouncementScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 10,
      ),
      body: Column(
        children: [
          SegmentedButtonSlide(
            entries: const [
              SegmentedButtonSlideEntry(label: "My Reports"),
              SegmentedButtonSlideEntry(label: "News"),
              SegmentedButtonSlideEntry(label: "Community"),
              SegmentedButtonSlideEntry(label: "Announcements"),
            ],
            selectedEntry: _selected,
            onChange: (selected) => setState(() => _selected = selected),
            colors: SegmentedButtonSlideColors(
              barColor: Colors.grey.shade200,
              backgroundSelectedColor: Color.fromRGBO(0, 52, 146, 1),
            ),
            slideShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
            margin: const EdgeInsets.all(10),
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            borderRadius: BorderRadius.circular(100),
            selectedTextStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            unselectedTextStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(39, 54, 79, 1),
            ),
            hoverTextStyle: GoogleFonts.poppins(
              color: Colors.black,
            ),
          ),

          
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0), 
                  end: Offset.zero,
                ).animate(animation);

                return SlideTransition(
                  position: slideAnimation,
                  child: child,
                );
              },
              child: Container(
                key: ValueKey<int>(_selected),
                child: _screens[_selected],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
