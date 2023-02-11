import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/students/students_module.dart';

class AppModule extends Module{
  @override
  List<Bind<Object>> get binds => [
  ];

  @override
  List<ModularRoute> get routes => [
    ModuleRoute('/', module: HomeModule()),
    ModuleRoute(AppRoutes.studentsRoute, module: StudentsModule()),
  ];
}