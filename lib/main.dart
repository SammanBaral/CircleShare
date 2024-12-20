import 'package:circle_share/view/login_view.dart';
// import 'package:circle_share/view/onboard_screen_view.dart';
import 'package:circle_share/view/splash_screen_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', 
      routes: {
        '/': (context) => SplashScreenView(), 
        '/home': (context) => LoginView(),    
      },
    ),
  );
}
