import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/core/time/bloc/week_number_bloc.dart';
import 'package:schedule/core/time/current_time.dart';
import 'package:schedule/main.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:schedule/modules/settings/settings_repository.dart';

final class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

final class HomePageState extends State<HomePage> with WidgetsBindingObserver, RouteAware {
  int _weekNumber = 1;

  @override
  void initState() {
    _weekNumber = CurrentTime.weekNumber;
    // context.addListener(_navigateListener);
    WidgetsBinding.instance.addObserver(this);

    inject<FavoriteScheduleBloc>().add(OpenMainFavSchedule());

    var settingsState = BlocProvider.of<SettingsBloc>(context).state;
    if (settingsState is SettingsLoaded && settingsState.autoWeekIndexSet) {
      inject<WeekNumberBloc>().add(CheckWeekNumber());
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      var settingsState = BlocProvider.of<SettingsBloc>(context).state;
      if (settingsState is SettingsLoaded && settingsState.autoWeekIndexSet) {
        inject<WeekNumberBloc>().add(CheckWeekNumber());
      }
    }
  }

  @override
  Future<bool> didPopRoute() {
    setState(() {
      _weekNumber = CurrentTime.weekNumber;
    });
    return super.didPopRoute();
  }

  @override
  void dispose() {
    // context.removeListener(_navigateListener);
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPop() {
    super.didPop();
    _navigateListener();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _navigateListener();
  }

  void _navigateListener() {
      setState(() {
        _weekNumber = CurrentTime.weekNumber;
      });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      /// события, добавленные здесь, будут активироваться каждый setState!
      providers: [
        BlocProvider.value(value: inject<FavoriteScheduleBloc>()),
        BlocProvider.value(value: inject<WeekNumberBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FavoriteScheduleBloc, FavoriteScheduleState>(
            listener: (context, state) async {
              if (state is FavoriteScheduleLoaded && state.isFromMainPage) {
                context.pushNamed(
                  AppRoutes.favoriteListRoute + AppRoutes.favoriteScheduleRoute,
                  arguments: [
                    state.scheduleModel.name,
                    state.scheduleModel.type,
                    (await RepositoryProvider.of<SettingsRepository>(context)
                        .loadSettings())[SettingsTypes.autoUpdate],
                  ],
                );
              }
            },
          ),
          BlocListener<WeekNumberBloc, WeekNumberState>(
            listener: (context, state) {
              if (state is WeekNumberLoaded) {
                BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                  settingType: SettingsTypes.weekIndexShifting,
                  value: state.weekShifting.toString(),
                ));
                setState(() {
                  _weekNumber = CurrentTime.weekNumber;
                });
              }
            },
          ),
        ],
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
          _appBarBottom(),
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
                  context.pushNamed(
                    AppRoutes.searchRoute,
                    arguments: [ScheduleType.student],
                  );
                },
              ),
              PopupMenuItem(
                child: const Text('Преподаватель'),
                onTap: () {
                  context.pushNamed(
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
            context.pushNamed(AppRoutes.settingsRoute);
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  Widget _appBarBottom() {
    return Row(
      children: [
        BlocBuilder<WeekNumberBloc, WeekNumberState>(
          builder: (context, state) {
            if (state is WeekNumberLoading) {
              return Container(
                margin: const EdgeInsets.only(right: 8.0),
                height: 14,
                width: 14,
                child: const CircularProgressIndicator(
                  color: Colors.grey,
                  strokeWidth: 2,
                ),
              );
            }

            if (state is WeekNumberError) {
              return const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.grey,
                  size: 16,
                ),
              );
            }

            return const SizedBox();
          },
        ),
        Expanded(
          child: Text(
            '$_weekNumber неделя',
            style: const TextStyle(fontSize: 16),
          ),
        )
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
              context.pushNamed(AppRoutes.favoriteListRoute);
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
                    context.pushNamed(AppRoutes.favoriteListRoute);
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
                      () => context.pushNamed(AppRoutes.classesRoute),
                      () => context.pushNamed(AppRoutes.zoClassesRoute),
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
                      () => context.pushNamed(AppRoutes.teachersRoute),
                      () => context.pushNamed(AppRoutes.zoTeachersRoute),
                      bottomText:
                          'Расписание преподавателей заочного отделения не имеет '
                          'возможности обновления из избранного',
                    );
                    //context.pushNamed(AppRoutes.teachersRoute);
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
                    context.pushNamed(AppRoutes.studentsRoute);
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

  Widget _homeElevatedButtonContent(String text, FaIconData icon) {
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
      builder: (sheetContext) {
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
                onPressed: () {
                  Navigator.pop(sheetContext);
                  dayPress();
                },
                child: const Row(
                  children: [
                    Icon(Icons.sunny),
                    SizedBox(width: 16),
                    Text('Очное отделение'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  nightPress();
                },
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
