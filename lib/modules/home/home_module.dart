import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/parser/parser.dart';
import 'package:schedule/core/parser/students_parser.dart';
import 'package:schedule/core/parser/teachers_parser.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/modules/classrooms/classrooms_module.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_module.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';
import 'package:schedule/modules/home/home_page.dart';
import 'package:schedule/core/main_repository.dart';
import 'package:schedule/modules/search/search_module.dart';
import 'package:schedule/modules/settings/settings_module.dart';
import 'package:schedule/modules/students/students_module.dart';
import 'package:schedule/modules/teachers/teachers_module.dart';

class HomeModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(FavoriteButtonBloc.new);
    i.addSingleton(FavoriteScheduleBloc.new);
    i.addSingleton(Logger.new);
    i.addSingleton(FavoriteRepository.new);
    i.addSingleton(MainRepository.new);
    i.addSingleton(TeachersParser.new);
    i.addSingleton(StudentsParser.new);
    i.addSingleton(Parser.new);
  }

  @override
  void exportedBinds(i) {
    //i.addSingleton(MainRepository.new);
    //i.addSingleton(FavoriteRepository.new);
  }

  BindConfig<T> blocConfig<T extends Bloc>() {
    return BindConfig(
      notifier: (bloc) => bloc.stream,
      onDispose: (bloc) => bloc.close(),
    );
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const HomePage());

    r.module(AppRoutes.studentsRoute, module: StudentsModule());
    r.module(AppRoutes.settingsRoute, module: SettingsModule());
    r.module(AppRoutes.teachersRoute, module: TeachersModule());
    r.module(AppRoutes.classesRoute, module: ClassroomsModule());
    r.module(AppRoutes.favoriteListRoute, module: FavoriteModule());
    r.module(AppRoutes.searchRoute, module: SearchModule());
  }

  //@override
  //List<Module> get imports => [this];
}
