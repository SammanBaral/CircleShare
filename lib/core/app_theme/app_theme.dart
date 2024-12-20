import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    // Light theme primary color
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.white, // Light background color

    // Font family
    fontFamily: 'Montserrat Regular',

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white, // Light AppBar background
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black), // Icons in black
      titleTextStyle: TextStyle(
        color: Colors.black, // Title text in black
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat Regular',
      ),
    ),

    // ElevatedButton theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        foregroundColor: Colors.white, // Text in white
        backgroundColor: Colors.black, // Black button background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100], // Light background for input fields
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      hintStyle: TextStyle(color: Colors.grey[600]), // Hint text color
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),

    // TextButton theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black, // Text in black
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat Regular',
        ),
      ),
    ),

    // Floating Action Button theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.black, // Black FAB background
      foregroundColor: Colors.white, // White FAB icon
    ),

    // Card theme
    cardTheme: CardTheme(
      margin: EdgeInsets.all(8),
      elevation: 2,
      color: Colors.white, // Light card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Icon theme
    iconTheme: IconThemeData(
      color: Colors.black, // Black icons
    ),

    // Text theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black, // Black text
        fontFamily: 'Montserrat Regular',
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black, // Headline text in black
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.grey[800], // Body text in dark grey
      ),
    ),
  );
}
