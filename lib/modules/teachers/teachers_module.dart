import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';
import 'package:schedule/modules/teachers/view/departments_page.dart';
import 'package:schedule/modules/teachers/view/faculties_page.dart';

final teachersModule = createModule(
    path: AppRoutes.teachersRoute,
    register: (c) {
      c.addSingleton(FacultyBloc.new);
      c.addSingleton(DepartmentBloc.new);

      c.route('/', child: (context, rs) => const FacultiesPage());
      c.route(AppRoutes.departmentsRoute,
          child: (context, rs) => DepartmentsPage(
              facultyState: rs.arguments! as CurrentFacultyLoaded));
    });
