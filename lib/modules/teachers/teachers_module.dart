import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';
import 'package:schedule/modules/teachers/repositories/teachers_repository.dart';
import 'package:schedule/modules/teachers/view/faculties_page.dart';

class TeachersModule extends Module{
  @override
  List<Bind<Object>> get binds => [
    Bind((i) => TeachersRepository()),
    Bind((i) => FacultyBloc(i.get<TeachersRepository>())),
  ];

  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (context, args) => const FacultiesPage())
  ];

  @override
  List<Module> get imports => [
    HomeModule(),
  ];
}