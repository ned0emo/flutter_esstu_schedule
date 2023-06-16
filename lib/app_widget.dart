import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:schedule/modules/settings/settings_repository.dart';
import 'package:schedule/themes/dark.dart';
import 'package:schedule/themes/primary.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SettingsRepository(),
      child: BlocProvider<SettingsBloc>(
        create: (context) =>
        SettingsBloc(RepositoryProvider.of(context))
          ..add(LoadSettings()),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'Расписание ВСГУТУ',
              routeInformationParser: Modular.routeInformationParser,
              routerDelegate: Modular.routerDelegate,
              theme: state is SettingsLoaded && state.darkTheme ? DarkTheme()
                  .data : PrimaryTheme().data,
            );
          },
        ),
      ),
    );
  }
}
