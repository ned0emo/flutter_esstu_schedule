import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:schedule/core/time/current_time.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/schedule_time_data.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/core/view/lesson_section.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';

class SchedulePageBody extends StatefulWidget {
  final ScheduleModel? scheduleModel;

  const SchedulePageBody({super.key, required this.scheduleModel});

  @override
  State<StatefulWidget> createState() => SchedulePageBodyState();
}

/// Добавлять сюда еще setState очень осторожно
class SchedulePageBodyState extends State<SchedulePageBody>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  /// Индекс с учетом отсутствия некоторых дней недели
  /// Вычисляется в ScheduleModel, либо, если все дни недели показаны,
  /// равен индексу дня недели в STD
  late int currentDayOfWeekIndex;

  /// Абсолютное значение индекса пары, независимо от пустых пар
  late int currentLessonIndex;

  /// Необходимое количество вкладок в зависимости от очного/заочного
  /// или от настройки "скрывать пустые дни недели"
  late int tabCount;

  late int numOfWeeks;

  /// Список дней недели для показа всех дней недели включая пустые
  late Iterable<String> daysOfWeek;

  /// Дата недель для аудиторий заочного
  late List<String?> weekDates;

  bool get isCurrentWeek => selectedWeekIndex == CurrentTime.weekIndex;

  int numOfLessons = 6;
  int lastTabIndex = 0;
  int selectedWeekIndex = 0;

  /// Для отмены выбора сегодняшнего дня во время смены недели.
  /// Сначала всегда держать true.
  /// Вообще супер важная переменная, перед сменой номера недели выключать,
  /// после операций с вкладками в build() обратно включать
  bool isScheduleChanged = true;

  bool isZo = false;

  ///настройки
  bool showEmptyDays = true;
  bool showEmptyLessons = true;
  bool showTabDate = true;

  TabController? _tabController;

  int _weekButtonTapCount = 0;

  @override
  void initState() {
    super.initState();

    numOfWeeks = widget.scheduleModel!.numOfWeeks;
    currentDayOfWeekIndex = CurrentTime.dayOfWeekIndex;
    currentLessonIndex = _getCurrentLessonIndex;

    final settingsState = BlocProvider.of<SettingsBloc>(context).state;
    if (settingsState is SettingsLoaded) {
      showEmptyDays = !settingsState.hideSchedule;
      showEmptyLessons = !settingsState.hideLesson;
      showTabDate = settingsState.showTabDate;
    }
  }

  /// Смена дня недели. [number] нужен для конкретного выбора через длинное
  /// нажатие кнопки. Иначе плюсует до тех пор, пока не станет больше равно, чем
  /// [numOfWeeks]. Тогда возвращает к нулю
  void _changeWeekNumber({int? number}) {
    isScheduleChanged = false;
    setState(() {
      selectedWeekIndex = number ??
          (selectedWeekIndex + 1 >= numOfWeeks ? 0 : selectedWeekIndex + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.scheduleModel == null || widget.scheduleModel!.isEmpty) {
      return const Center(child: Text('Расписание отсутствует'));
    }

    isZo = widget.scheduleModel!.isZo;
    if (isZo) numOfLessons = 7;

    if (isScheduleChanged) {
      selectedWeekIndex = CurrentTime.weekIndex;
      numOfWeeks = widget.scheduleModel!.numOfWeeks;

      if (selectedWeekIndex >= numOfWeeks) {
        selectedWeekIndex = 0;
      }
    }

    daysOfWeek = showEmptyDays && !isZo
        ? ScheduleTimeData.daysOfWeekShort.take(6)
        : widget.scheduleModel!.weeks[selectedWeekIndex].daysOfWeek
            .where((element) => element.lessons.isNotEmpty)
            .map((e) => e.dayOfWeekName);

    tabCount = daysOfWeek.length;

    //выбор инишл вкладки только при первом открытии расписания
    //и не у заочников
    if (isScheduleChanged && !isZo) {
      if (showEmptyDays) {
        lastTabIndex = CurrentTime.dayOfWeekIndex % 6;
      } else {
        lastTabIndex = widget.scheduleModel!
            .dayOfWeekByAbsoluteIndex(selectedWeekIndex, currentDayOfWeekIndex);
      }
    } else {
      lastTabIndex = min(max(tabCount - 1, 0), lastTabIndex);
    }
    //включать после смены номера недели
    isScheduleChanged = true;

    _tabController?.dispose();
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
      initialIndex: lastTabIndex,
    );

    _tabController!.addListener(() {
      lastTabIndex = _tabController!.index;
    });

    ///даты для точного выбора недели у заочников
    weekDates = widget.scheduleModel!.weekDates;

    return _tabBody();
  }

  Widget _tabBody() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              tabCount > 0
                  ? _tabBarView()
                  : const Center(
                      child: Text(
                        'Расписание отсутствует',
                        textAlign: TextAlign.center,
                      ),
                    ),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ListView(
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    /// Здесь SizedBox'ы потому что паддинг отображает
                    /// "пустоту", когда кнопка за экраном
                    const SizedBox(width: 5),
                    _favoriteButton(),
                    const SizedBox(width: 5),
                    FilledButton(
                      onPressed: () {
                        _weekButtonTapCount++;
                        if (_weekButtonTapCount > 2) {
                          _longPressHintDialog();
                          _weekButtonTapCount = 0;
                        }
                        _changeWeekNumber();
                      },
                      onLongPress: () => _changeWeekDialog(context),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 5),
                          Text(weekDates[selectedWeekIndex] ??
                              ('${selectedWeekIndex + 1} неделя'
                                  '${isCurrentWeek && !isZo ? ' (Сейчас)' : ''}')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
        _tabBar(),
      ],
    );
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: _tabController,
      children: daysOfWeek.map(
        (e) {
          final currentDaySchedule = widget.scheduleModel!
              .getDayOfWeekByShortName(e, selectedWeekIndex);

          if (currentDaySchedule == null) {
            return const Center(
              child: Text('Расписание на этот день отсутствует'),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 50),
            children: showEmptyLessons
                ? List.generate(
                    numOfLessons,
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
                  )
                : currentDaySchedule.lessons
                    .map(
                      (lesson) => LessonSection(
                        lesson: lesson,
                        isCurrentLesson: isCurrentWeek &&
                            currentDayOfWeekIndex ==
                                currentDaySchedule.dayOfWeekIndex &&
                            currentLessonIndex == lesson.lessonIndex,
                      ),
                    )
                    .toList(),
          );
        },
      ).toList(),
    );
  }

  Widget _tabBar() {
    Map<String, String> dates;
    double fontSize;

    if (showTabDate && !isZo) {
      fontSize = 12;
      final formatter = DateFormat("\ndd.MM");
      final mondayDate = DateTime.now().subtract(
        Duration(
          days: CurrentTime.dayOfWeekIndex - (!isCurrentWeek ? 7 : 0),
        ),
      );

      dates = Map.fromEntries(daysOfWeek.map(
        (day) => MapEntry(
          day,
          formatter.format(
            mondayDate.add(
              Duration(
                days: ScheduleTimeData.daysOfWeekShort.indexOf(day),
              ),
            ),
          ),
        ),
      ));
    } else {
      fontSize = 14;
      dates = Map.fromEntries(
        List.generate(
          daysOfWeek.length,
          (index) => MapEntry(daysOfWeek.elementAt(index), ''),
        ),
      );
    }

    return TabBar(
      controller: _tabController,
      tabs: daysOfWeek.map((e) {
        final currentDaySchedule =
            widget.scheduleModel!.getDayOfWeekByShortName(e, selectedWeekIndex);

        if (currentDaySchedule == null) {
          return Tab(
            iconMargin: EdgeInsets.zero,
            child: FittedBox(
              fit: BoxFit.none,
              child: Text(
                ScheduleTimeData.daysOfWeekShort.indexOf(e) ==
                            currentDayOfWeekIndex &&
                        isCurrentWeek
                    ? '[$e]${dates[e]}'
                    : (e + dates[e].toString()),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                  color: Colors.grey,
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
                    '${currentDaySchedule.dayOfWeekName}\n'
                    '${currentDaySchedule.dayOfWeekDate}',
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
                        ? '[${currentDaySchedule.dayOfWeekName}]${dates[e]}'
                        : currentDaySchedule.dayOfWeekName +
                            dates[e].toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                numOfWeeks,
                (index) => SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      _changeWeekNumber(number: index);
                      Navigator.of(context).pop();
                    },
                    child: Text(weekDates[index] ??
                        ('${index + 1} неделя'
                            '${index == CurrentTime.weekIndex && !isZo ? ' (Сейчас)' : ''}')),
                  ),
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
      scheduleType: widget.scheduleModel!.type,
      name: widget.scheduleModel!.name,
    ));

    ///Провайдер вызывать из виджета уровнем выше
    return BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
      builder: (context, state) {
        return FilledButton(
          onPressed: () {
            if (state is FavoriteExist) {
              Modular.get<FavoriteButtonBloc>().add(DeleteSchedule(
                  name: widget.scheduleModel!.name,
                  scheduleType: widget.scheduleModel!.type));
              return;
            }

            if (state is FavoriteDoesNotExist) {
              Modular.get<FavoriteButtonBloc>()
                  .add(SaveSchedule(scheduleModel: widget.scheduleModel!));

              if (widget.scheduleModel?.type != ScheduleType.zoTeacher &&
                  widget.scheduleModel?.type != ScheduleType.zoClassroom &&
                  widget.scheduleModel?.type != ScheduleType.classroom) {
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

  void _addToMainDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Открывать при запуске приложения?'),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Нет')),
            FilledButton(
                onPressed: () {
                  Modular.get<FavoriteButtonBloc>().add(AddFavoriteToMainPage(
                    scheduleType: widget.scheduleModel!.type,
                    name: widget.scheduleModel!.name,
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('Да')),
          ],
        );
      },
    );
  }

  void _longPressHintDialog() {
    /// Вызов через BlocProvider, так как SettingsBloc отсутствует в модуляре
    final state = BlocProvider.of<SettingsBloc>(context).state;
    if (state is SettingsLoaded && !state.weekButtonHint) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Подсказка'),
            content: const Text(
              'Для точного выбора недели нажмите и '
              'удерживайте кнопку смены недель',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.weekButtonHint,
                        value: 'true'));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Больше не\nпоказывать')),
              FilledButton(
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

  int get _getCurrentLessonIndex {
    int currentLesson = -1;
    final currentTime = CurrentTime.minuteOfDay;
    if (currentTime >= 540 && currentTime <= 635) {
      currentLesson = 0;
    } else if (currentTime >= 645 && currentTime <= 740) {
      currentLesson = 1;
    } else if (currentTime >= 780 && currentTime <= 875) {
      currentLesson = 2;
    } else if (currentTime >= 885 && currentTime <= 980) {
      currentLesson = 3;
    } else if (currentTime >= 985 && currentTime <= 1080) {
      currentLesson = 4;
    } else if (currentTime >= 1085 && currentTime <= 1180) {
      currentLesson = 5;
    }

    return currentLesson;
  }

  //int get _getCurrentWeekIndex => (Jiffy.now().weekOfYear + 1) % 2;

  //int get _getCurrentDayOfWeekIndex => Jiffy.now().dateTime.weekday - 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _tabController?.dispose();

    super.dispose();
  }
}
