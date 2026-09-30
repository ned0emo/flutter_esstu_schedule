import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/zo_teachers/bloc/zo_teachers_bloc.dart';
import 'package:schedule/modules/zo_teachers/view/zo_teachers_page.dart';

import '../../core/static/app_routes.dart';

final zoTeachersModule = createModule(
    path: AppRoutes.zoTeachersRoute,
    register: (c) {
      c.addSingleton(ZoTeachersBloc.new);

      c.route('/', child: (context, rs) => const ZoTeachersPage());
    });
