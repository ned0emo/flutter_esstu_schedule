import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/zo_classrooms/bloc/zo_classroom_bloc.dart';
import 'package:schedule/modules/zo_classrooms/view/zo_classrooms_page.dart';

class ZoClassroomsModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(ZoClassroomsBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const ZoClassroomsPage());
  }

  @override
  List<Module> get imports => [HomeModule()];
}
