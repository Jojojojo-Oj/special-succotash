import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(1, 47, 72, 1),
      body: Center(
        child:  SpinKitFadingCircle(
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}