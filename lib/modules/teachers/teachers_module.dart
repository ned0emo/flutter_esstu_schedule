import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';
import 'package:schedule/modules/teachers/view/departments_page.dart';
import 'package:schedule/modules/teachers/view/faculties_page.dart';

class TeachersModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(FacultyBloc.new);
    i.addSingleton(DepartmentBloc.new);
  }

  @override
  void routes(RouteManager r) {
    //final args = r.args;
    r.child('/', child: (context) => const FacultiesPage());
    r.child(AppRoutes.departmentsRoute,
        child: (context) => DepartmentsPage(facultyState: r.args.data));
  }

  @override
  List<Module> get imports => [HomeModule()];
}
