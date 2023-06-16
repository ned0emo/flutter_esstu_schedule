import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/home/home_module.dart';
import 'package:schedule/modules/settings/views/debug_page.dart';
import 'package:schedule/modules/settings/views/settings_page.dart';

class SettingsModule extends Module {
  @override
  List<Bind<Object>> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const SettingsPage()),
        ChildRoute(AppRoutes.debugRoute,
            child: (context, args) => const DebugPage()),
      ];

  @override
  List<Module> get imports => [HomeModule()];
}
