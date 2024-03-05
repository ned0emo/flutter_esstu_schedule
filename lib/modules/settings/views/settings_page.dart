import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/logger/logger.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _version = '3.8.5';

  @override
  Widget build(BuildContext context) {
    final logger = Modular.get<Logger>();

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
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
                  value: state.darkTheme,
                  onChanged: (value) {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.darkTheme,
                        value: value.toString()));
                  },
                ),
                SwitchListTile(
                  title: const Text('Автоматическое обновление расписания в избранном'),
                  value: state.autoUpdate,
                  onChanged: (value) {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.autoUpdate,
                        value: value.toString()));
                  },
                ),
                SwitchListTile(
                  title: const Text('Скрывать пустые дни недели'),
                  value: state.hideSchedule,
                  onChanged: (value) {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.hideSchedule,
                        value: value.toString()));
                  },
                ),
                SwitchListTile(
                  title: const Text('Скрывать пустые занятия'),
                  value: state.hideLesson,
                  onChanged: (value) {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.hideLesson,
                        value: value.toString()));
                  },
                ),
                SwitchListTile(
                  title: const Text('Показывать даты дней недели'),
                  value: state.showTabDate,
                  onChanged: (value) {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.showTabDate,
                        value: value.toString()));
                  },
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
                ListTile(
                  title: const Text('Очистить данные'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Очистить данные?'),
                          content: const Text('Избранное и логи будут удалены.'
                              ' Настройки приложения вернутся к значениям по умолчанию.'),
                          actions: [
                            FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Нет')),
                            OutlinedButton(
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
                  title: const Text('Версия $_version'),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: '\nРазработчик: Александр Суворов'
                                '\nКафедра "Программная инженерия и искусственный интеллект"'
                                '\nВСГУТУ'
                                '\n\nОб ошибках в работе приложения сообщать здесь:',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            )),
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
                                logger.error(
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
                          text: '\nhttps://www.flaticon.com/authors/smashicons',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              try {
                                await launchUrl(Uri.parse(
                                    'https://www.flaticon.com/authors/smashicons'));
                              } catch (exception, stack) {
                                logger.error(
                                  title: "Ошибка открытия ссылки на flaticon",
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
                                logger.error(
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
                  ),
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
    );
  }
}
