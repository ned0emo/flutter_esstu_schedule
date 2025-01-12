import 'package:flutter/material.dart';
import 'package:schedule/themes/theme.dart';

class PrimaryTheme extends ThemeTemplate {
  @override
  ThemeData get data => ThemeData(
    applyElevationOverlayColor: false,
    canvasColor: Colors.grey[100],
    colorScheme: ColorScheme.light(
      primary: Colors.deepOrange,
      surface: Colors.grey[50] ?? Colors.white,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFCF0EE),
        foregroundColor: Colors.grey[850],
        iconColor: Colors.grey[850],
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: const CardTheme(surfaceTintColor: Colors.white, color: Colors.white),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black87,
        iconColor: Colors.black87,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
      ),
    ),
    tabBarTheme: const TabBarTheme(labelColor: Colors.black87),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey[800],
    ),
  );
}
