import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';
import 'package:schedule/modules/teachers/repositories/teachers_repository.dart';
import 'package:schedule/modules/teachers/view/departments_page.dart';
import 'package:schedule/modules/teachers/view/faculties_page.dart';

class TeachersModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind((i) => TeachersRepository()),
        Bind((i) => FacultyBloc(i.get())),
        Bind((i) => DepartmentBloc(i.get()))
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const FacultiesPage()),
        ChildRoute(
          AppRoutes.departmentsRoute,
          child: (context, args) => DepartmentsPage(facultyState: args.data[0]),
        ),
      ];

  @override
  List<Module> get imports => [
        HomeModule(),
      ];
}
