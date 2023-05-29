import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/classrooms/bloc/classrooms_bloc.dart';
import 'package:schedule/modules/classrooms/repositories/classrooms_repository.dart';
import 'package:schedule/modules/classrooms/view/classrooms_page.dart';
import 'package:schedule/modules/home/home_module.dart';

class ClassroomsModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind((i) => ClassroomsRepository()),
        Bind((i) => ClassroomsBloc(i.get<ClassroomsRepository>())
          ..add(LoadClassroomsSchedule())),
      ];

  @override
  List<ModularRoute> get routes =>
      [ChildRoute('/', child: (context, args) => const ClassroomsPage())];

  @override
  List<Module> get imports => [HomeModule()];
}
