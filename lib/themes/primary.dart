import 'package:flutter/material.dart';
import 'package:schedule/themes/theme.dart';

class PrimaryTheme extends ThemeTemplate {
  @override
  ThemeData get data => ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.deepOrange,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.grey[850],
            minimumSize: const Size(150, 46),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardTheme(surfaceTintColor: Colors.grey[100]),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
          ),
        ),
        tabBarTheme: const TabBarTheme(labelColor: Colors.black87),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[800],
        ),
      );
}
