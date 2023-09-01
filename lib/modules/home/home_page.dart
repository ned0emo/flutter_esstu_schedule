import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schedule/core/settings_types.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:schedule/modules/settings/settings_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: Modular.get<FavoriteScheduleBloc>()
            ..add(OpenMainFavSchedule()),
        ),
        BlocProvider.value(value: BlocProvider.of<SettingsBloc>(context)),
      ],
      child: BlocListener<FavoriteScheduleBloc, FavoriteScheduleState>(
        listener: (context, state) async {
          if (state is FavoriteScheduleLoaded && state.isFromMainPage) {
            Modular.to.pushNamed(
              AppRoutes.favoriteListRoute + AppRoutes.favoriteScheduleRoute,
              arguments: [
                state.scheduleName,
                state.scheduleType,
                (await RepositoryProvider.of<SettingsRepository>(context)
                        .loadSettings())[SettingsTypes.autoUpdate] ==
                    'true',
              ],
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Расписание ВСГУТУ'),
            actions: [
              IconButton(
                onPressed: () {
                  Modular.to.pushNamed(AppRoutes.settingsRoute);
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return Image.asset(
                      state is SettingsLoaded && state.darkTheme
                          ? 'assets/newlogo_dark.png'
                          : 'assets/newlogo.png',
                      width: 180,
                      height: 180,
                    );
                  },
                ),
                const SizedBox(height: 20),
                GridView.count(
                  padding: const EdgeInsets.all(15),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  primary: false,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.studentsRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Учебные группы',
                        FontAwesomeIcons.userGroup,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.teachersRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Преподаватели',
                        FontAwesomeIcons.graduationCap,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.classesRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Аудитории',
                        FontAwesomeIcons.bookOpen,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.favoriteListRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Избранное',
                        FontAwesomeIcons.solidStar,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Поиск расписания'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Modular.to.popAndPushNamed(
                                  AppRoutes.searchRoute,
                                  arguments: [ScheduleType.student],
                                );
                              },
                              child: const Text(
                                'Учебная группа',
                                style: TextStyle(fontSize: 20),
                              )),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Modular.to.popAndPushNamed(
                                  AppRoutes.searchRoute,
                                  arguments: [ScheduleType.teacher],
                                );
                              },
                              child: const Text(
                                'Преподаватель',
                                style: TextStyle(fontSize: 20),
                              )),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget _homeElevatedButtonContent(String text, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        FaIcon(icon, size: 70),
        Expanded(
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
