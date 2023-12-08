import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/settings_types.dart';
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
      ],
      child: BlocListener<FavoriteScheduleBloc, FavoriteScheduleState>(
        listener: (context, state) async {
          if (state is FavoriteScheduleLoaded && state.isFromMainPage) {
            Modular.to.pushNamed(
              AppRoutes.favoriteListRoute + AppRoutes.favoriteScheduleRoute,
              arguments: [
                state.scheduleModel.name,
                state.scheduleModel.type,
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
                onPressed: () => _searchDialog(context),
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Modular.to.pushNamed(AppRoutes.settingsRoute);
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 50),
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return Image.asset(
                      state is SettingsLoaded && state.darkTheme
                          ? 'assets/newlogo_dark.png'
                          : 'assets/newlogo_warm.png',
                    );
                  },
                ),
              ),
              ListView(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 30.0,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.favoriteListRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Избранное',
                        FontAwesomeIcons.solidStar,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.classesRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Аудитории',
                        FontAwesomeIcons.bookOpen,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.teachersRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Преподаватели',
                        FontAwesomeIcons.graduationCap,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.studentsRoute);
                      },
                      child: _homeElevatedButtonContent(
                        'Учебные группы',
                        FontAwesomeIcons.userGroup,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeElevatedButtonContent(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        FaIcon(icon),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _searchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Поиск расписания'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
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
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
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
  }
}
