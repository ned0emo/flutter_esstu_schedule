import 'package:flutter/material.dart';
import 'package:schedule/themes/theme.dart';

class PrimaryTheme extends ThemeTemplate {
  @override
  ThemeData get data => ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.deepOrange,
          surface: Colors.grey[100] ?? Colors.white,
          background: Colors.grey[100] ?? Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.grey[850],
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: const CardTheme(surfaceTintColor: Colors.white),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
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
