import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData highContrastLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.highContrastLight(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.blueAccent,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
    ),
  );

  static final ThemeData highContrastDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.highContrastDark(
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.tealAccent,
      onSecondary: Colors.black,
      surface: Colors.grey[900]!,
      onSurface: Colors.white,
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    ),
  );
}
