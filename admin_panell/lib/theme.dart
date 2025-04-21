import 'package:flutter/material.dart';

// Basic theme definition for Admin Panel
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue, // Or your preferred primary color
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // Add other light theme configurations
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white, // Title/icon color
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Button background color
        foregroundColor: Colors.white, // Button text/icon color
      ),
    ),
    // Define text themes, input decorations, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch:
        Colors.blue, // Keep consistent or use a different dark theme color
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // Add other dark theme configurations
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey, // Example dark app bar
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700], // Example dark button
        foregroundColor: Colors.white,
      ),
    ),
    // Define text themes, input decorations, etc.
  );
}
