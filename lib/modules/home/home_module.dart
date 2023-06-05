import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/classrooms/classrooms_module.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_module.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';
import 'package:schedule/modules/home/home_page.dart';
import 'package:schedule/modules/search/search_module.dart';
import 'package:schedule/modules/settings/bloc/settings_cubit.dart';
import 'package:schedule/modules/settings/bloc/settings_repository.dart';
import 'package:schedule/modules/settings/settings_module.dart';
import 'package:schedule/modules/students/students_module.dart';
import 'package:schedule/modules/teachers/teachers_module.dart';

class HomeModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.singleton((i) => SettingsRepository()),
        Bind.singleton((i) => SettingsCubit(i.get<SettingsRepository>()),
            export: true),
        Bind.singleton((i) => FavoriteRepository()),
        Bind.singleton((i) => FavoriteButtonBloc(i.get<FavoriteRepository>()),
            export: true),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const HomePage()),
        ModuleRoute(AppRoutes.studentsRoute, module: StudentsModule()),
        ModuleRoute(AppRoutes.settingsRoute, module: SettingsModule()),
        ModuleRoute(AppRoutes.teachersRoute, module: TeachersModule()),
        ModuleRoute(AppRoutes.classesRoute, module: ClassroomsModule()),
        ModuleRoute(AppRoutes.favoriteListRoute, module: FavoriteModule()),
        ModuleRoute(AppRoutes.searchRoute, module: SearchModule()),
      ];
}
