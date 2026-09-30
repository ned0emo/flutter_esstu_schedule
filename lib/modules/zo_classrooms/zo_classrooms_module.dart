import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/zo_classrooms/bloc/zo_classroom_bloc.dart';
import 'package:schedule/modules/zo_classrooms/view/zo_classrooms_page.dart';

import '../../core/static/app_routes.dart';

final zoClassroomsModule = createModule(
    path: AppRoutes.zoClassesRoute,
    register: (c) {
      c.addSingleton(ZoClassroomsBloc.new);

      c.route('/', child: (context, rs) => const ZoClassroomsPage());
    });
