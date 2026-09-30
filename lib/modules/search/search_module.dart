import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/modules/search/search_list_bloc/search_list_bloc.dart';
import 'package:schedule/modules/search/search_schedule_bloc/search_schedule_bloc.dart';
import 'package:schedule/modules/search/view/search_list_page.dart';
import 'package:schedule/modules/search/view/search_schedule_page.dart';

final searchModule = createModule(
    path: AppRoutes.searchRoute,
    register: (c) {
      c.addSingleton(SearchListBloc.new);
      c.addSingleton(SearchScheduleBloc.new);

      c.route('/',
          child: (context, rs) =>
              SearchListPage(scheduleType: (rs.arguments! as List<String>)[0]));
      c.route(AppRoutes.searchingScheduleRoute, child: (context, rs) {
        final args = rs.arguments! as List<String?>;

        return SearchSchedulePage(
          scheduleName: args[0]!,
          scheduleType: args[1]!,
          scheduleLink1: args[2]!,
          scheduleLink2: args[3],
        );
      });
    });
