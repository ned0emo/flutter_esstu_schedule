import 'package:flutter/material.dart';
import 'package:schedule/themes/theme.dart';

//0xFFA2E8E4 light blue???
//0xFF6EB5C0 dark blue
//0xFF006C84 dark dark blue
class PrimaryTheme extends ThemeTemplate {
  @override
  ThemeData get data => ThemeData(
    switchTheme: SwitchThemeData(
      //TODO: Серый цвет выключенного свича
      thumbColor: MaterialStateProperty.all<Color>(const Color(0xFF6EB5C0)),
      trackColor: MaterialStateProperty.all<Color>(const Color(0xFFA2E0F4)),
      //overlayColor: MaterialStateProperty.all<Color>(const Color(0xFFA2E8E4)),
    ),
    colorScheme: const ColorScheme.light(
      background: Colors.white,
      primary: Color(0xFF006C84),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        minimumSize: const Size(150, 46),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6EB5C0),
    ),
  );
}
