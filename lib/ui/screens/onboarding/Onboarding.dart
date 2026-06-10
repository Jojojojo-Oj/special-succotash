import 'package:agapay_users/ui/screens/onboarding/AllowNotification.dart';
import 'package:agapay_users/ui/screens/onboarding/RescueDispatch.dart';
import 'package:agapay_users/ui/screens/onboarding/TypeRequest.dart';
import 'package:agapay_users/ui/screens/onboarding/VerifiedSafety.dart';
import 'package:agapay_users/ui/screens/onboarding/WelcomeAgapay.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              
              children: [
                SecondOnboarding(controller: _controller,),
                FourthOnboarding(controller: _controller,),
                ThirdOnboarding(controller: _controller),
                FifthOnboarding(controller: _controller),
                SixthOnboarding(controller: _controller,)


              ],
            )
           ),
          
           SmoothPageIndicator(
            controller: _controller, 
            count: 5,
            effect: const ExpandingDotsEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Color.fromARGB(255, 6, 37, 53)
            ),
           ),

           SizedBox(height: 50,)
        ],       
      ),
    );
  }
}