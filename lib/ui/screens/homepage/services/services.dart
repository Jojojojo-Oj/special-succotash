import 'package:agapay_users/ui/screens/HOMEPAGE/SERVICES/eco%20bag/reEcobag.dart';
import 'package:agapay_users/ui/screens/homepage/services/evacuation/evacuation_ui.dart';
import 'package:agapay_users/ui/screens/homepage/services/facilities/facilities.dart';
import 'package:agapay_users/ui/screens/homepage/services/hotlines/hotline.dart';
import 'package:agapay_users/ui/screens/homepage/services/safety%20tips/safety_tips.dart';
import 'package:agapay_users/ui/screens/homepage/services/serviceButton.dart';
import 'package:agapay_users/features/weather/presentation/screens/weather_screen.dart';
import 'package:flutter/material.dart';

class ServicesContent extends StatelessWidget {
  const ServicesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 30,
              runSpacing: 30,
              children: [
                
                ServiceButton(
                  icon: 'assets/images/safety.png',
                  label: 'Safety Tips',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SafetyTips()));
                    
                  },
                ),

                
                ServiceButton(
                  icon: 'assets/images/gobag.png',
                  label: 'E-Go Bag',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReEcoBag()));

                  },
                ),

                
                ServiceButton(
                  icon: 'assets/images/hotline.png',
                  label: 'Hotlines',
                  onTap: () {
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => HotlinePage()));
                  },
                ),

                
                ServiceButton(
                  icon: 'assets/images/hospital.png',
                  label: 'Evacuation',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EvacuationUi()));
                    
                  },
                ),

                
                ServiceButton(
                  icon: 'assets/images/building_police.png',
                  label: 'Facilities',
                  onTap: () {
                    Navigator.push(
                      context, 
                    MaterialPageRoute(builder: (context) => Facilities()));
                  },
                ),

                ServiceButton(
                  icon: 'assets/images/cloudy.png',
                  label: 'Weather',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherScreen()));
                  },
                ),

     
                
              ],
            ),
          ),
        ),
      );
  }
}
