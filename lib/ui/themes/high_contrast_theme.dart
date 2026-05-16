import 'package:flutter/material.dart';

class AppHighContrastTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.black,
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.yellow.shade700,
        error: Colors.red.shade800,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow.shade600,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}