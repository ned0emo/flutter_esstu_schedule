import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/app_module.dart';
import 'package:schedule/modules/settings/settings_page.dart';

class SettingsModule extends Module {
  @override
  List<Bind<Object>> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const SettingsPage()),
      ];

  @override
  List<Module> get imports => [
        AppModule(),
      ];
}
