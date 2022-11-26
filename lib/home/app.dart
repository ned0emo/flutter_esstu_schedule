import 'package:flutter/material.dart';
import 'package:schedule/home/view/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Расписание ВСГУТУ',
      theme: ThemeData(
        applyElevationOverlayColor: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF006C84),
          secondary: Color(0xFF6EB5C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFE2E8E4),
      ),
      home: const HomePage(),
    );
  }
}