import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
import 'package:schedule/modules/favorite/favorite_update_bloc/favorite_update_bloc.dart';
import 'package:schedule/modules/favorite/view/favorite_list_page.dart';
import 'package:schedule/modules/favorite/view/favorite_schedule_page.dart';
import 'package:schedule/modules/home/home_module.dart';

class FavoriteModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind((i) => FavoriteListBloc(i.get())),
        Bind((i) => FavoriteUpdateBloc(i.get())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const FavoriteListPage()),
        ChildRoute(
          AppRoutes.favoriteScheduleRoute,
          child: (context, args) => FavoriteSchedulePage(
            scheduleName: args.data[0],
            scheduleType: args.data[1],
            isAutoUpdateEnabled: args.data[2],
          ),
        ),
      ];

  @override
  List<Module> get imports => [HomeModule()];
}
