import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/classrooms/bloc/classrooms_bloc.dart';
import 'package:schedule/modules/classrooms/repositories/classrooms_repository.dart';
import 'package:schedule/modules/classrooms/view/classrooms_page.dart';
import 'package:schedule/modules/home/home_module.dart';

class ClassroomsModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(ClassroomsRepository.new);
    i.addSingleton(ClassroomsBloc.new);
      //..add(LoadClassroomsSchedule()));
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const ClassroomsPage());
  }

  @override
  List<Module> get imports => [HomeModule()];
}
