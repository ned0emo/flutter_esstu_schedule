import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/search/search_list_bloc/search_list_bloc.dart';
import 'package:schedule/modules/search/search_repository.dart';
import 'package:schedule/modules/search/view/search_list_page.dart';

class SearchModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind((i) => SearchRepository()),
        Bind((i) => SearchListBloc(i.get())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (context, args) => SearchListPage(scheduleType: args.data[0]))
      ];

  @override
  List<Module> get imports => [
        HomeModule(),
      ];
}
