import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/modules/settings/views/debug_page.dart';
import 'package:schedule/modules/settings/views/settings_page.dart';

final settingsModule = createModule(
    path: AppRoutes.settingsRoute,
    register: (c) {
      c.route('/', child: (context, rs) => const SettingsPage());
      c.route(AppRoutes.debugRoute, child: (context, rs) => const DebugPage());
    });
