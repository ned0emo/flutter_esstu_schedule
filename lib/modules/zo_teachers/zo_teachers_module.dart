import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/zo_teachers/bloc/zo_teachers_bloc.dart';
import 'package:schedule/modules/zo_teachers/view/zo_teachers_page.dart';

class ZoTeachersModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(ZoTeachersBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const ZoTeachersPage());
  }

  @override
  List<Module> get imports => [HomeModule()];
}
