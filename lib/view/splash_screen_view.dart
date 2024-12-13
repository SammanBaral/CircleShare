import 'package:circle_share/view/onboard_screen_view.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to OnboardingScreen after 1 second
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/circle_logo.png'),
            // Icon(
            //   Icons.share,
            //   size: 100,
            //   color: Colors.white,
            // ),
            // SizedBox(height: 16),
            // Text(
            //   "CircleShare",
            //   style: TextStyle(
            //     fontSize: 28,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
