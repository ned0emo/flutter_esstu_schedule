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
import 'package:schedule/modules/search/search_schedule_bloc/search_schedule_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_bloc.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';

//TODO: расписание избранного
//TODO: удаление лишних настроек
//TODO: замена ненужных stateful виджетов на stateless
//TODO: доработка темной темы
class SchedulePageBody<T1 extends Bloc> extends StatefulWidget {
  const SchedulePageBody({super.key});

  @override
  State<StatefulWidget> createState() => SchedulePageBodyState<T1>();
}

class SchedulePageBodyState<T1 extends Bloc> extends State<SchedulePageBody>
    with AutomaticKeepAliveClientMixin {
  late int selectedWeekIndex;

  /// Индекс с учетом отсутствия некоторых дней недели
  late int currentDayOfWeekIndex;

  /// Абсолютное значение индекса пары, независимо от пустых пар
  late int currentLessonIndex;

  /// Модель текущего расписания (со всеми неделями разумеется)
  late ScheduleModel currentScheduleModel;

  bool get isCurrentWeek =>
      selectedWeekIndex == ScheduleTimeData.getCurrentWeekIndex();

  int numOfWeeks = 0;
  int initialTabIndex = 0;
  int currentDropdownIndex = 0;

  bool isNeedToSelectTab = false;

  bool isZo = false;

  String? selectedDropdownElement;

  TabController? tabController;

  @override
  void initState() {
    super.initState();

    selectedWeekIndex = ScheduleTimeData.getCurrentWeekIndex();
    currentDayOfWeekIndex = ScheduleTimeData.getCurrentDayOfWeekIndex();
    currentLessonIndex = ScheduleTimeData.getCurrentLessonIndex();
  }

  /// Смена дня недели. [number] нужен для конкретного выбора через длинное
  /// нажатие кнопки. Иначе плюсует до тех пор, пока не станет больше равно, чем
  /// [numOfWeeks]. Тогда возвращает к нулю
  void _changeWeekNumber({int? number}) {
    setState(() {
      isNeedToSelectTab = false;
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
        selectedDropdownElement = null;
        currentDropdownIndex = 0;
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
                state.teachersScheduleData[currentDropdownIndex];

            numOfWeeks = currentScheduleModel.numOfWeeks;
            if (selectedWeekIndex >= numOfWeeks) {
              selectedWeekIndex = 0;
            }

            initialTabIndex = currentScheduleModel.dayOfWeekByAbsoluteIndex(
                selectedWeekIndex, currentDayOfWeekIndex);

            return _tabController(
              dropDownName: 'Преподаватель:   ',
              dropDownList:
                  state.teachersScheduleData.map((e) => e.name).toList(),
            );
          }

          if (state is ClassroomsLoaded) {
            if (state.scheduleMap.isEmpty) {
              return const Center(child: Text('Ошибка. Список корпусов пуст'));
            }

            if (state.scheduleMap[state.currentBuildingName] == null ||
                state.scheduleMap[state.currentBuildingName]!.isEmpty) {
              return const Center(child: Text('Ошибка. Список аудиторий пуст'));
            }

            currentScheduleModel = state
                .scheduleMap[state.currentBuildingName]![currentDropdownIndex];

            numOfWeeks = currentScheduleModel.numOfWeeks;
            if (selectedWeekIndex >= numOfWeeks) {
              selectedWeekIndex = 0;
            }

            initialTabIndex = currentScheduleModel.dayOfWeekByAbsoluteIndex(
                selectedWeekIndex, currentDayOfWeekIndex);

            return _tabController(
              dropDownName: 'Аудитория:   ',
              dropDownList: state.scheduleMap[state.currentBuildingName]!
                  .map((e) => e.name)
                  .toList(),
            );
          }

          if (state is CurrentGroupLoaded) {
            if (state.scheduleModel.isEmpty) {
              return const Center(child: Text('Расписание отсутствует'));
            }

            currentScheduleModel = state.scheduleModel;

            isZo = currentScheduleModel.isZo;

            numOfWeeks = currentScheduleModel.numOfWeeks;
            if (selectedWeekIndex >= numOfWeeks) {
              selectedWeekIndex = 0;
            }

            if (!isZo) {
              initialTabIndex = currentScheduleModel.dayOfWeekByAbsoluteIndex(
                  selectedWeekIndex, currentDayOfWeekIndex);
            }

            return _tabController();
          }

          if (state is SearchScheduleLoaded) {
            if (state.scheduleModel.isEmpty) {
              return const Center(child: Text('Расписание отсутствует'));
            }

            currentScheduleModel = state.scheduleModel;

            isZo = currentScheduleModel.isZo;

            numOfWeeks = currentScheduleModel.numOfWeeks;
            if (selectedWeekIndex >= numOfWeeks) {
              selectedWeekIndex = 0;
            }

            if (!isZo) {
              initialTabIndex = currentScheduleModel.dayOfWeekByAbsoluteIndex(
                  selectedWeekIndex, currentDayOfWeekIndex);
            }

            return _tabController();
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _tabController({String? dropDownName, List<String>? dropDownList}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isCurrentWeek && isNeedToSelectTab) {
        tabController?.animateTo(currentScheduleModel.dayOfWeekByAbsoluteIndex(
            selectedWeekIndex, currentDayOfWeekIndex));
      }
    });
    final tabCount = currentScheduleModel.weekLength(selectedWeekIndex);

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
            if (dropDownList != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dropDownName.toString(),
                      style: const TextStyle(fontSize: 18)),
                  DropdownButton<String>(
                    items: dropDownList
                        .map((el) => DropdownMenuItem<String>(
                              value: el,
                              child: Text(el),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      if (value == selectedDropdownElement) return;

                      setState(() {
                        isNeedToSelectTab = true;
                        selectedWeekIndex =
                            ScheduleTimeData.getCurrentWeekIndex();
                        selectedDropdownElement = value;
                        currentDropdownIndex = dropDownList.indexOf(value!);
                      });
                    },
                    value: selectedDropdownElement ?? dropDownList[0],
                  ),
                ],
              ),
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  tabCount > 0
                      ? TabBarView(
                          controller: tabController,
                          children: currentScheduleModel
                              .weeks[selectedWeekIndex].daysOfWeek
                              .map(
                                (lessons) => SingleChildScrollView(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 50.0),
                                    child: Column(
                                      children: lessons.lessons
                                          .map<Widget>(
                                            (lesson) => LessonSection(
                                              lesson: lesson,
                                              isCurrentLesson:
                                                  currentDayOfWeekIndex ==
                                                          lessons
                                                              .dayOfWeekIndex &&
                                                      currentLessonIndex ==
                                                          lesson.lessonIndex,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const Center(child: Text('Расписание отсутствует')),
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
            TabBar(
              controller: tabController,
              tabs: currentScheduleModel.weeks[selectedWeekIndex].daysOfWeek
                  .map(
                    (e) => e.dayOfWeekDate != null
                        ? Tab(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: e.dayOfWeekName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.color,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\n${e.dayOfWeekDate}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.color,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Tab(
                            text: e.dayOfWeekIndex == currentDayOfWeekIndex &&
                                    isCurrentWeek
                                ? '[${e.dayOfWeekName}]'
                                : e.dayOfWeekName,
                          ),
                  )
                  .toList(),
            ),
          ],
        );
      }),
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
              (index) => TextButton(
                onPressed: () {
                  setState(() => _changeWeekNumber(number: index));
                  Navigator.of(context).pop();
                },
                child: Text('${index + 1} неделя'
                    '${index == ScheduleTimeData.getCurrentWeekIndex() && !isZo ? ' (Сейчас)' : ''}'),
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

    ///Провайдер вызывать из виджеты уровнем выше
    return BlocListener<FavoriteButtonBloc, FavoriteButtonState>(
      listener: (context, state) {
        if (state is FavoriteExist && state.isNeedSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Добавлено в избранное'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        if (state is FavoriteDoesNotExist && state.isNeedSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Удалено из избранного'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
      },
      child: BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
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
                Modular.get<FavoriteButtonBloc>().add(SaveSchedule(
                  name: currentScheduleModel.name,
                  scheduleType: currentScheduleModel.type,
                  scheduleList: [],
                  link1: currentScheduleModel.link1,
                  link2: currentScheduleModel.link2,
                ));

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
      ),
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
