import 'package:flutter/material.dart';
import 'package:schedule/themes/theme.dart';

//0xFFA2E8E4 light blue???
//0xFF6EB5C0 dark blue
//0xFF006C84 dark dark blue
class PrimaryTheme extends ThemeTemplate {
  @override
  ThemeData get data => ThemeData(
    colorScheme: const ColorScheme.light(
      background: Colors.white,
      primary: Color(0xFF006C84),
      secondary: Color(0xFF6EB5C0),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        foregroundColor: Colors.grey[850],
        backgroundColor: Colors.white,
        minimumSize: const Size(150, 46),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black87,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF006C84),
      ),
    ),
    tabBarTheme: const TabBarTheme(labelColor: Colors.black87),
  );
}
