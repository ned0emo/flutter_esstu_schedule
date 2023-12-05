import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/schedule_time_data.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/core/view/lesson_section.dart';
import 'package:schedule/modules/classrooms/bloc/classrooms_bloc.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/search/search_schedule_bloc/search_schedule_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_bloc.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';

class SchedulePageBody<T1 extends Bloc> extends StatefulWidget {
  const SchedulePageBody({super.key});

  @override
  State<StatefulWidget> createState() => SchedulePageBodyState<T1>();
}

class SchedulePageBodyState<T1 extends Bloc> extends State<SchedulePageBody>
    with AutomaticKeepAliveClientMixin {
  late int selectedWeekIndex;

  /// Индекс с учетом отсутствия некоторых дней недели
  /// Вычисляется в ScheduleModel, либо, если все дни недели показаны,
  /// равен индексу дня недели в STD
  late int currentDayOfWeekIndex;

  /// Абсолютное значение индекса пары, независимо от пустых пар
  late int currentLessonIndex;

  /// Модель текущего расписания (со всеми неделями разумеется)
  late ScheduleModel currentScheduleModel;

  bool get isCurrentWeek =>
      selectedWeekIndex == ScheduleTimeData.getCurrentWeekIndex();

  int numOfWeeks = 0;
  int initialTabIndex = 0;

  /// Для отмены выбора сегодняшнего дня во время смены недели
  bool isNeedToSelectTab = false;

  bool isZo = false;

  bool showEmptyDays = true;
  bool showEmptyLessons = true;

  TabController? tabController;

  @override
  void initState() {
    super.initState();

    selectedWeekIndex = ScheduleTimeData.getCurrentWeekIndex();
    currentDayOfWeekIndex = ScheduleTimeData.getCurrentDayOfWeekIndex();
    currentLessonIndex = ScheduleTimeData.getCurrentLessonIndex();

    final settingsState = BlocProvider.of<SettingsBloc>(context).state;
    if (settingsState is SettingsLoaded) {
      showEmptyDays = !settingsState.hideSchedule;
      showEmptyLessons = !settingsState.hideLesson;
    }
  }

  /// Смена дня недели. [number] нужен для конкретного выбора через длинное
  /// нажатие кнопки. Иначе плюсует до тех пор, пока не станет больше равно, чем
  /// [numOfWeeks]. Тогда возвращает к нулю
  void _changeWeekNumber({int? number}) {
    isNeedToSelectTab = false;
    setState(() {
      selectedWeekIndex = number ??
          (selectedWeekIndex + 1 >= numOfWeeks ? 0 : selectedWeekIndex + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener(
      bloc: Modular.get<T1>(),
      listener: (context, state) {
        setState(() {
          selectedWeekIndex = ScheduleTimeData.getCurrentWeekIndex();
          currentDayOfWeekIndex = ScheduleTimeData.getCurrentDayOfWeekIndex();
        });
      },
      child: BlocBuilder(
        bloc: Modular.get<T1>(),
        builder: (context, state) {
          if (state is DepartmentLoaded) {
            if (state.teachersScheduleData.isEmpty) {
              return const Center(
                  child: Text('Ошибка. Список преподавателй пуст'));
            }

            currentScheduleModel =
                state.teachersScheduleData[state.currentTeacherIndex];

            numOfWeeks = currentScheduleModel.numOfWeeks;
            if (selectedWeekIndex >= numOfWeeks) {
              selectedWeekIndex = 0;
            }

            initialTabIndex = showEmptyDays
                ? ScheduleTimeData.getCurrentDayOfWeekIndex() % 6
                : currentScheduleModel.dayOfWeekByAbsoluteIndex(
                    selectedWeekIndex, currentDayOfWeekIndex);

            return _tabController();
          }

          if (state is ClassroomsLoaded) {
            if (state.scheduleMap.isEmpty) {
              return const Center(child: Text('Ошибка. Список корпусов пуст'));
            }

            if (state.scheduleMap[state.currentBuildingName] == null ||
                state.scheduleMap[state.currentBuildingName]!.isEmpty) {
              return const Center(child: Text('Ошибка. Список аудиторий пуст'));
            }

            currentScheduleModel = state.scheduleMap[
                state.currentBuildingName]![state.currentClassroomIndex];

            numOfWeeks = currentScheduleModel.numOfWeeks;
            if (selectedWeekIndex >= numOfWeeks) {
              selectedWeekIndex = 0;
            }

            initialTabIndex = showEmptyDays
                ? ScheduleTimeData.getCurrentDayOfWeekIndex() % 6
                : currentScheduleModel.dayOfWeekByAbsoluteIndex(
                    selectedWeekIndex, currentDayOfWeekIndex);

            return _tabController();
          }

          Widget otherTabController(ScheduleModel scheduleModel) {
            if (scheduleModel.isEmpty) {
              return const Center(child: Text('Расписание отсутствует'));
            }

            currentScheduleModel = scheduleModel;

            isZo = currentScheduleModel.isZo;

            numOfWeeks = currentScheduleModel.numOfWeeks;
            if (selectedWeekIndex >= numOfWeeks) {
              selectedWeekIndex = 0;
            }

            if (!isZo) {
              initialTabIndex = showEmptyDays
                  ? ScheduleTimeData.getCurrentDayOfWeekIndex() % 6
                  : currentScheduleModel.dayOfWeekByAbsoluteIndex(
                      selectedWeekIndex, currentDayOfWeekIndex);
            }

            return _tabController();
          }

          if (state is CurrentGroupLoaded) {
            return otherTabController(state.scheduleModel);
          }

          if (state is SearchScheduleLoaded) {
            return otherTabController(state.scheduleModel);
          }

          if (state is FavoriteScheduleLoaded) {
            return otherTabController(state.scheduleModel);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _tabController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isNeedToSelectTab) {
        isNeedToSelectTab = true;
        return;
      }

      if (isCurrentWeek) {
        tabController?.animateTo(showEmptyDays
            ? ScheduleTimeData.getCurrentDayOfWeekIndex() % 6
            : currentScheduleModel.dayOfWeekByAbsoluteIndex(
                selectedWeekIndex, currentDayOfWeekIndex));
      }
    });

    final tabCount = !showEmptyDays || isZo
        ? currentScheduleModel.weekLength(selectedWeekIndex)
        : 6;
    final daysOfWeek = ScheduleTimeData.daysOfWeekSmall.take(6);

    return DefaultTabController(
      length: tabCount,
      initialIndex: initialTabIndex,
      animationDuration: const Duration(milliseconds: 100),
      child: Builder(builder: (context) {
        /// Инициализация контроллера для выбора текущего дня
        /// недели после смены расписания
        tabController = DefaultTabController.of(context);

        return Column(
          children: [
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  tabCount > 0
                      ? _tabBarView(tabCount, daysOfWeek)
                      : const Center(
                          child: Text(
                            'Расписание отсутствует',
                            textAlign: TextAlign.center,
                          ),
                        ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(5),
                    child: ListView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        _favoriteButton(),
                        const SizedBox(width: 15),
                        FilledButton(
                          onPressed: () => _changeWeekNumber(),
                          onLongPress: () => _changeWeekDialog(context),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month),
                              const SizedBox(width: 5),
                              Text('${selectedWeekIndex + 1} неделя'
                                  '${isCurrentWeek && !isZo ? ' (Сейчас)' : ''}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _tabBar(tabCount, daysOfWeek),
          ],
        );
      }),
    );
  }

  Widget _tabBarView(int tabCount, Iterable<String> daysOfWeek) {
    if (isZo || !showEmptyDays) {
      return TabBarView(
        controller: tabController,
        children:
            currentScheduleModel.weeks[selectedWeekIndex].daysOfWeek.map((e) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: showEmptyLessons
                  ? Column(
                      children: List.generate(
                        isZo ? 7 : 6,
                        (index) {
                          return LessonSection(
                            lesson: e.lessons.firstWhereOrNull(
                                (element) => element.lessonNumber == index + 1),
                            isCurrentLesson: false,
                            lessonNumber: index + 1,
                          );
                        },
                      )..add(
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 5.0,
                            ),
                            child: const Text(
                              'Скрыть пустые занятия можно в настройках',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                    )
                  : Column(
                      children: e.lessons
                          .map<Widget>(
                            (lesson) => LessonSection(
                              lesson: lesson,
                              isCurrentLesson: false,
                            ),
                          )
                          .toList(),
                    ),
            ),
          );
        }).toList(),
      );
    }

    return TabBarView(
      controller: tabController,
      children: daysOfWeek.map((e) {
        final currentDaySchedule =
            currentScheduleModel.getDayOfWeekByShortName(e, selectedWeekIndex);

        if (currentDaySchedule == null) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: Text('Расписание на этот день отсутствует'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 60.0, right: 15.0),
                child: Text(
                  'Скрыть пустые дни недели можно в настройках',
                  textAlign: TextAlign.right,
                ),
              )
            ],
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: showEmptyLessons
                ? Column(
                    children: List.generate(
                      6,
                      (index) {
                        return LessonSection(
                          lesson: currentDaySchedule.lessons.firstWhereOrNull(
                              (element) => element.lessonNumber == index + 1),
                          isCurrentLesson: isCurrentWeek &&
                              currentDayOfWeekIndex ==
                                  currentDaySchedule.dayOfWeekIndex &&
                              currentLessonIndex == index,
                          lessonNumber: index + 1,
                        );
                      },
                    )..add(
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 5.0,
                          ),
                          child: const Text(
                            'Скрыть пустые занятия можно в настройках',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                  )
                : Column(
                    children: currentDaySchedule.lessons
                        .map<Widget>(
                          (lesson) => LessonSection(
                            lesson: lesson,
                            isCurrentLesson: isCurrentWeek &&
                                currentDayOfWeekIndex ==
                                    currentDaySchedule.dayOfWeekIndex &&
                                currentLessonIndex == lesson.lessonIndex,
                          ),
                        )
                        .toList(),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _tabBar(int tabCount, Iterable<String> daysOfWeek) {
    if (isZo || !showEmptyDays) {
      return TabBar(
        controller: tabController,
        tabs: currentScheduleModel.weeks[selectedWeekIndex].daysOfWeek.map((e) {
          return Tab(
            iconMargin: EdgeInsets.zero,
            child: FittedBox(
              fit: BoxFit.none,
              child: e.dayOfWeekDate != null
                  ? Text(
                      '${e.dayOfWeekName}\n${e.dayOfWeekDate}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      e.dayOfWeekIndex == currentDayOfWeekIndex && isCurrentWeek
                          ? '[${e.dayOfWeekName}]'
                          : e.dayOfWeekName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
            ),
          );
        }).toList(),
      );
    }

    return TabBar(
      controller: tabController,
      tabs: daysOfWeek.map((e) {
        final currentDaySchedule =
            currentScheduleModel.getDayOfWeekByShortName(e, selectedWeekIndex);
        if (currentDaySchedule == null) {
          return Tab(
            iconMargin: EdgeInsets.zero,
            child: FittedBox(
              fit: BoxFit.none,
              child: Text(
                ScheduleTimeData.daysOfWeekSmall.indexOf(e) ==
                            currentDayOfWeekIndex &&
                        isCurrentWeek
                    ? '[$e]'
                    : e,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return Tab(
          iconMargin: EdgeInsets.zero,
          child: FittedBox(
            fit: BoxFit.none,
            child: currentDaySchedule.dayOfWeekDate != null
                ? Text(
                    '${currentDaySchedule.dayOfWeekName}\n${currentDaySchedule.dayOfWeekDate}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  )
                : Text(
                    currentDaySchedule.dayOfWeekIndex ==
                                currentDayOfWeekIndex &&
                            isCurrentWeek
                        ? '[${currentDaySchedule.dayOfWeekName}]'
                        : currentDaySchedule.dayOfWeekName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  void _changeWeekDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выберите неделю'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              numOfWeeks,
              (index) => SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() => _changeWeekNumber(number: index));
                    Navigator.of(context).pop();
                  },
                  child: Text('${index + 1} неделя'
                      '${index == ScheduleTimeData.getCurrentWeekIndex() && !isZo ? ' (Сейчас)' : ''}'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _favoriteButton() {
    Modular.get<FavoriteButtonBloc>().add(CheckSchedule(
      scheduleType: currentScheduleModel.type,
      name: currentScheduleModel.name,
    ));

    ///Провайдер вызывать из виджета уровнем выше
    return BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
      builder: (context, state) {
        return FilledButton(
          onPressed: () {
            if (state is FavoriteExist) {
              Modular.get<FavoriteButtonBloc>().add(DeleteSchedule(
                  name: currentScheduleModel.name,
                  scheduleType: currentScheduleModel.type));
              return;
            }

            if (state is FavoriteDoesNotExist) {
              Modular.get<FavoriteButtonBloc>()
                  .add(SaveSchedule(scheduleModel: currentScheduleModel));

              if (currentScheduleModel.type == ScheduleType.classroom) {
                _noUpdateDialog();
              } else {
                _addToMainDialog();
              }
            }
          },
          child: state is FavoriteExist
              ? const Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 5),
                    Text('Из избранного'),
                  ],
                )
              : const Row(
                  children: [
                    Icon(Icons.star_border),
                    SizedBox(width: 5),
                    Text('В избранное'),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _addToMainDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Открывать при запуске приложения?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Нет')),
            TextButton(
                onPressed: () {
                  Modular.get<FavoriteButtonBloc>().add(AddFavoriteToMainPage(
                    scheduleType: currentScheduleModel.type,
                    name: currentScheduleModel.name,
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('Да')),
          ],
        );
      },
    );
  }

  Future<void> _noUpdateDialog() async {
    /// Вызов через BlocProvider, так как SettingsBloc отсутствует в модуляре
    final state = BlocProvider.of<SettingsBloc>(context).state;
    if (state is SettingsLoaded && !state.noUpdateClassroom) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Внимание'),
            content: const Text(
                'Расписание аудиторий не имеет возможности обновления из избранного'),
            actions: [
              TextButton(
                  onPressed: () {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.noUpdateClassroom,
                        value: 'true'));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Больше не показывать')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ок')),
            ],
          );
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
