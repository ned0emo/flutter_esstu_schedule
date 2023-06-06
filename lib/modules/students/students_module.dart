import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_bloc.dart';
import 'package:schedule/modules/students/views/students_page.dart';

class StudentsModule extends Module{
  @override
  List<Bind<Object>> get binds => [
    Bind((i) => AllGroupsBloc(i.get())),
    Bind((i) => CurrentGroupBloc(i.get())),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => const StudentsPage())
  ];

  @override
  List<Module> get imports => [
    HomeModule(),
  ];
}