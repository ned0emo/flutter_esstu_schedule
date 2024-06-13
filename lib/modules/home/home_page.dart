import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:schedule/modules/settings/settings_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _weekNumber = 1;

  @override
  void initState() {
    _weekNumber = (Jiffy.now().weekOfYear + 1) % 2 + 1;
    Modular.to.addListener(_navigateListener);
    super.initState();
  }

  @override
  void dispose() {
    Modular.to.removeListener(_navigateListener);
    super.dispose();
  }

  void _navigateListener() {
    if (Modular.to.navigateHistory.length == 1) {
      setState(() {
        _weekNumber = (Jiffy.now().weekOfYear + 1) % 2 + 1;
      });
    }
  }

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
          appBar: _appBar(),
          body: _body(context),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Расписание ВСГУТУ'),
          Text(
            '$_weekNumber неделя',
            style: const TextStyle(fontSize: 16),
          )
        ],
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.search),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: const Text('Учебная группа'),
                onTap: () {
                  Modular.to.pushNamed(
                    AppRoutes.searchRoute,
                    arguments: [ScheduleType.student],
                  );
                },
              ),
              PopupMenuItem(
                child: const Text('Преподаватель'),
                onTap: () {
                  Modular.to.pushNamed(
                    AppRoutes.searchRoute,
                    arguments: [ScheduleType.teacher],
                  );
                },
              )
            ];
          },
        ),
        IconButton(
          onPressed: () {
            Modular.to.pushNamed(AppRoutes.settingsRoute);
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 50),
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
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? 1) < 0) {
              Modular.to.pushNamed(AppRoutes.favoriteListRoute);
            }
          },
          child: ListView(
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
                    _bottomSheet(
                      context,
                      () => Modular.to.popAndPushNamed(AppRoutes.classesRoute),
                      () =>
                          Modular.to.popAndPushNamed(AppRoutes.zoClassesRoute),
                      bottomText: 'Расписание аудиторий не имеет '
                          'возможности обновления из избранного',
                    );
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
                    _bottomSheet(
                      context,
                      () => Modular.to.popAndPushNamed(AppRoutes.teachersRoute),
                      () =>
                          Modular.to.popAndPushNamed(AppRoutes.zoTeachersRoute),
                      bottomText:
                          'Расписание преподавателей заочного отделения не имеет '
                          'возможности обновления из избранного',
                    );
                    //Modular.to.pushNamed(AppRoutes.teachersRoute);
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
        ),
      ],
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

  void _bottomSheet(
    BuildContext context,
    void Function() dayPress,
    void Function() nightPress, {
    String? bottomText,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 24.0,
          ),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(
                onPressed: dayPress,
                child: const Row(
                  children: [
                    Icon(Icons.sunny),
                    SizedBox(width: 16),
                    Text('Очное отделение'),
                  ],
                ),
              ),
              TextButton(
                onPressed: nightPress,
                child: const Row(
                  children: [
                    Icon(Icons.nightlight),
                    SizedBox(width: 16),
                    Text('Заочное отделение'),
                  ],
                ),
              ),
              if (bottomText != null) const Divider(),
              if (bottomText != null) Text(bottomText),
            ],
          ),
        );
      },
    );
  }
}
