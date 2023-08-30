import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_bloc.dart';
import 'package:schedule/modules/students/views/students_page.dart';

class StudentsModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(AllGroupsBloc.new);
    i.addSingleton(CurrentGroupBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const StudentsPage());
  }

  @override
  List<Module> get imports => [HomeModule()];
}
