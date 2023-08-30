import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/students/students_module.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module('/', module: HomeModule());
    r.module(AppRoutes.studentsRoute, module: StudentsModule());
  }
}
