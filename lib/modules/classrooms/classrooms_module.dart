import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/classrooms/bloc/classrooms_bloc.dart';
import 'package:schedule/modules/classrooms/view/classrooms_page.dart';

import '../../core/static/app_routes.dart';

final classroomsModule = createModule(
    path: AppRoutes.classesRoute,
    register: (c) {
      c.addSingleton(ClassroomsBloc.new);
      c.route('/', child: (context, state) => const ClassroomsPage());
    });
