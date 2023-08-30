import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/search/search_list_bloc/search_list_bloc.dart';
import 'package:schedule/modules/search/search_repository.dart';
import 'package:schedule/modules/search/search_schedule_bloc/search_schedule_bloc.dart';
import 'package:schedule/modules/search/view/search_list_page.dart';
import 'package:schedule/modules/search/view/search_schedule_page.dart';

class SearchModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(SearchRepository.new);
    i.addSingleton(SearchListBloc.new);
    i.addSingleton(SearchScheduleBloc.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/',
        child: (context) => SearchListPage(scheduleType: r.args.data[0]));
    r.child(AppRoutes.searchingScheduleRoute,
        child: (context) => SearchSchedulePage(
              scheduleName: r.args.data[0],
              scheduleType: r.args.data[1],
              scheduleLink1: r.args.data[2],
              scheduleLink2: r.args.data[3],
            ));
  }

  @override
  List<Module> get imports => [HomeModule()];
}
