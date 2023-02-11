import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/themes/primary.dart';

class AppWidget extends StatelessWidget{
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Расписание ВСГУТУ',
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      theme: PrimaryTheme().data,
    );
  }
}