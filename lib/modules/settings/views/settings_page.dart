import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/core/settings_types.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: BlocProvider.value(
        value: BlocProvider.of<SettingsBloc>(context),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsLoaded) {
              return ListView(
                children: [
                  const ListTile(
                      title: Text(
                    'Основные',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  SwitchListTile(
                    title: const Text('Темная тема'),
                    subtitle: Text(state.darkThemeDescription),
                    value: state.darkTheme,
                    onChanged: (value) {
                      BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                          settingType: SettingsTypes.darkTheme,
                          value: value.toString()));
                    },
                    trackColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary;
                            }
                            return Colors.grey;
                          }),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Автоматическое обновление'),
                    subtitle: Text(state.autoUpdateDescription),
                    value: state.autoUpdate,
                    onChanged: (value) {
                      BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                          settingType: SettingsTypes.autoUpdate,
                          value: value.toString()));
                    },
                    trackColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary;
                            }
                            return Colors.grey;
                          }),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Отладка'),
                    onTap: () {
                      Modular.to.pushNamed(AppRoutes.settingsRoute + AppRoutes.debugRoute);
                    },
                  ),
                  const ListTile(
                      title: Text(
                    'О приложении',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  const ListTile(
                    title: Text('Версия 3.0.0'),
                    subtitle: Text('\nРазработчик: Александр Суворов'
                        '\nКафедра "Программная инженерия и искусственный интеллект"'
                        '\nВСГУТУ, 2022'
                        '\n\nСвязь с разработчиком:'
                        '\nAlexandr42suv@mail.ru'
                        '\n\nЗначок приложения основан на иконке от SmashIcons:'
                        '\nwww.flaticon.com/authors/smashicons'
                        '\n\nСоциализм или варварство'),
                  ),
                ],
              );
            }

            if (state is SettingsError) {
              return Center(child: Text(state.message));
            }

            return const Center(child: Text('Неизвестная ошибка'));
          },
        ),
      ),
    );
  }
}
