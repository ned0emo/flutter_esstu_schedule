import 'package:flutter/material.dart';
import 'package:schedule/themes/theme.dart';

//0xFFA2E8E4 light blue???
//0xFF6EB5C0 dark blue
//0xFF006C84 dark dark blue
class DarkTheme extends ThemeTemplate {
  @override
  ThemeData get data => ThemeData(
        colorScheme: const ColorScheme.light(
          //background: Colors.black87,
          primary: Color(0xFF002B34),
          secondary: Color(0xFF006C84),
          //surface: Colors.red,
          //primaryContainer: Colors.red,
          //onPrimaryContainer: Colors.red,
          //onSecondary: Colors.red,
          //secondaryContainer: Colors.red,
          //onSecondaryContainer: Colors.red,
          //tertiary: Colors.red,
          //onTertiary: Colors.red,
          //tertiaryContainer: Colors.red,
          //onTertiaryContainer: Colors.red,
          //error: Colors.red,
          //onError: Colors.red,
          //errorContainer: Colors.red,
          //onErrorContainer: Colors.red,
          //background: Colors.red,
          //onBackground: Colors.red,
          //onSurface: Colors.red,
          //surfaceVariant: Colors.red,
          //onSurfaceVariant: Colors.red,
          //outline: Colors.red,
          //outlineVariant: Colors.red,
          //shadow: Colors.red,
          //scrim: Colors.red,
          //inverseSurface: Colors.red,
          //onInverseSurface: Colors.red,
          //inversePrimary: Colors.red,
          //surfaceTint: Colors.red,
        ),
        cardColor: Colors.grey[900],
        dialogBackgroundColor: Colors.grey[800],
        canvasColor: Colors.black87,
        scaffoldBackgroundColor: Colors.black87,
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
        //visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            foregroundColor: Colors.grey[300],
            backgroundColor: Colors.grey[900],
            minimumSize: const Size(150, 46),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
          foregroundColor: Colors.white
        )),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[800],
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Colors.black87),
        tabBarTheme: const TabBarTheme(labelColor: Colors.white),
        dividerColor: Colors.grey[700],
      );
}
