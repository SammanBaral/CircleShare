import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
      // primarySwatch: Colors.red,
      scaffoldBackgroundColor: Colors.cyan[10],
      fontFamily: 'Montserrat Regular',
      appBarTheme: AppBarTheme(color: Colors.grey[100]),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat Regular'),
        backgroundColor: Colors.cyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      )));
}
