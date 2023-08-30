import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/app_module.dart';
import 'package:schedule/app_widget.dart';


void main() async {
  await Jiffy.setLocale('ru');
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
