import 'package:flutter/material.dart';
import 'package:schedule/themes/theme.dart';

class DarkTheme extends ThemeTemplate {
  @override
  ThemeData get data => ThemeData(
      colorScheme: const ColorScheme.dark(primary: Color(0xffa92c00)),
      cardTheme: CardTheme(surfaceTintColor: Colors.grey[700]),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.grey[300],
          backgroundColor: Colors.grey[900],
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[800],
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      tabBarTheme: const TabBarTheme(labelColor: Colors.white),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(foregroundColor: Colors.white)));
}
