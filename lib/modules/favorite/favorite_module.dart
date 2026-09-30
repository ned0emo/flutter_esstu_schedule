import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
import 'package:schedule/modules/favorite/favorite_update_bloc/favorite_update_bloc.dart';
import 'package:schedule/modules/favorite/view/favorite_list_page.dart';
import 'package:schedule/modules/favorite/view/favorite_schedule_page.dart';

final favoriteModule = createModule(
    path: AppRoutes.favoriteListRoute,
    register: (c) {
      c.addSingleton(FavoriteListBloc.new);
      c.addSingleton(FavoriteUpdateBloc.new);

      c.route('/', child: (context, rs) => const FavoriteListPage());
      c.route(AppRoutes.favoriteScheduleRoute, child: (context, rs) {
        final args = rs.arguments! as List<String?>;

        return FavoriteSchedulePage(
          scheduleName: args[0]!,
          scheduleType: args[1]!,
          isAutoUpdateEnabled: args[2] == 'true',
        );
      });
    });
