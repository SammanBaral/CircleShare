import 'package:circle_share/core/app_theme/app_theme.dart';
import 'package:circle_share/view/splash_screen_view.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      theme: getApplicationTheme(),
      routes: {
        "/": (context) => SplashScreenView(),
      },
    );
  }
}
