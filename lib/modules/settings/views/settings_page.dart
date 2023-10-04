import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/settings_types.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        return Theme.of(context).colorScheme.primary;
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
                        return Theme.of(context).colorScheme.primary;
                      }
                      return Colors.grey;
                    }),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Скрывать пустые занятия'),
                    value: state.hideSchedule,
                    onChanged: (value) {
                      BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                          settingType: SettingsTypes.hideSchedule,
                          value: value.toString()));
                    },
                    trackColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).colorScheme.primary;
                      }
                      return Colors.grey;
                    }),
                  ),
                  SwitchListTile(
                    title: const Text('Выделять тип занятия цветом'),
                    subtitle: Text(state.lessonColorDescription),
                    value: state.lessonColor,
                    onChanged: (value) {
                      BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                          settingType: SettingsTypes.lessonColor,
                          value: value.toString()));
                    },
                    trackColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).colorScheme.primary;
                      }
                      return Colors.grey;
                    }),
                  ),
                  const ListTile(
                      title: Text(
                    'Отладка',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  ListTile(
                    title: const Text('Логи'),
                    onTap: () {
                      Modular.to.pushNamed(
                          AppRoutes.settingsRoute + AppRoutes.debugRoute);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Очистить данные'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Очистить данные?'),
                            content: const Text(
                                'Избранное и логи будут удалены.'
                                ' Настройки приложения вернутся к значениям по умолчанию.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Нет')),
                              TextButton(
                                  onPressed: () {
                                    BlocProvider.of<SettingsBloc>(context)
                                        .add(ClearAll());
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Да'))
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const ListTile(
                      title: Text(
                    'О приложении',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  ListTile(
                      title: const Text('Версия 3.2.2'),
                      subtitle: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: '\nРазработчик: Александр Суворов'
                                    '\nКафедра "Программная инженерия и искусственный интеллект"'
                                    '\nВСГУТУ'
                                    '\n\nОб ошибках в работе приложения сообщать здесь:',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color)),
                            TextSpan(
                              text:
                                  '\nhttps://github.com/ned0emo/flutter_esstu_schedule/issues',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  try {
                                    await launchUrl(Uri.parse(
                                        'https://github.com/ned0emo/flutter_esstu_schedule/issues'));
                                  } catch (exception, stack) {
                                    Logger.error(
                                      title: "Ошибка открытия ссылки на github",
                                      exception: exception,
                                      stack: stack,
                                    );
                                  }
                                },
                            ),
                            TextSpan(
                                text:
                                    '\n\nЗначок приложения основан на иконке от SmashIcons:',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color)),
                            TextSpan(
                              text:
                                  '\nhttps://www.flaticon.com/authors/smashicons',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  try {
                                    await launchUrl(Uri.parse(
                                        'https://www.flaticon.com/authors/smashicons'));
                                  } catch (exception, stack) {
                                    Logger.error(
                                      title:
                                          "Ошибка открытия ссылки на flaticon",
                                      exception: exception,
                                      stack: stack,
                                    );
                                  }
                                },
                            ),
                            TextSpan(
                                text:
                                    '\n\nИконки на главной странице от FontAwesome:',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color)),
                            TextSpan(
                              text: '\nhttps://fontawesome.com/v4/icons',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  try {
                                    await launchUrl(Uri.parse(
                                        'https://fontawesome.com/v4/icons'));
                                  } catch (exception, stack) {
                                    Logger.error(
                                      title:
                                          "Ошибка открытия ссылки на fontawesome",
                                      exception: exception,
                                      stack: stack,
                                    );
                                  }
                                },
                            ),
                            TextSpan(
                                text: '\n\nСоциализм или варварство\n\n',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color)),
                          ],
                        ),
                      )
                      //Text('\nРазработчик: Александр Суворов'
                      //    '\nКафедра "Программная инженерия и искусственный интеллект"'
                      //    '\nВСГУТУ'
                      //    '\n\nСвязь с разработчиком:'
                      //    '\nhttps://github.com/ned0emo/flutter_esstu_schedule/issues'
                      //    '\n\nЗначок приложения основан на иконке от SmashIcons:'
                      //    '\nhttps://www.flaticon.com/authors/smashicons'
                      //    '\n\nИконки на главной странице от FontAwesome:'
                      //    '\nhttps://fontawesome.com/v4/icons'
                      //    '\n\nСоциализм или варварство\n\n'),
                      ),
                ],
              );
            }

            if (state is SettingsError) {
              return Center(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Логи'),
                      onTap: () {
                        Modular.to.pushNamed(
                            AppRoutes.settingsRoute + AppRoutes.debugRoute);
                      },
                    ),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Неизвестная ошибка'));
          },
        ),
      ),
    );
  }
}
