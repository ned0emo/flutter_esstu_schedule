import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/students/all_groups_bloc/all_groups_cubit.dart';
import 'package:schedule/students/current_group_bloc/current_group_cubit.dart';

class StudentsView extends Container {
  StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final allGroupsState = BlocProvider.of<AllGroupsCubit>(context).state;

    String firstTabStar = '';
    String secondTabStar = '';
    int weekNumber = 0;
    bool isZo = false;

    if (allGroupsState is CourseSelected) {
      weekNumber = allGroupsState.weekNumber;

      if (allGroupsState.typeLink2 != '') {
        isZo = true;
      } else if (weekNumber == 0) {
        firstTabStar = '★';
      } else {
        secondTabStar = '★';
      }
    }

    return DefaultTabController(
      length: isZo ? 4 : 2,
      initialIndex: weekNumber,
      child: Column(
        children: [
          allGroupsState is CourseSelected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Группа:',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: DropdownButton<String>(
                        value: allGroupsState.currentGroup,
                        items: allGroupsState.linkGroupMap.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),

                        ///
                        ///Выбор учебной группы
                        ///
                        onChanged: (value) {
                          BlocProvider.of<AllGroupsCubit>(context)
                              .selectGroup(value ?? '');

                          allGroupsState.typeLink2 == ''
                              ? BlocProvider.of<CurrentGroupCubit>(context)
                                  .loadCurrentGroup(allGroupsState.typeLink1 +
                                      (allGroupsState.linkGroupMap[value] ??
                                          ''))
                              : BlocProvider.of<CurrentGroupCubit>(context)
                                  .loadCurrentGroup(
                                      (allGroupsState.linkGroupMap[value] ??
                                          ''));
                        },
                      ),
                    ),
                  ],
                )
              : const Text('Ошибка загрузки'),
          Expanded(
            child: BlocBuilder<CurrentGroupCubit, CurrentGroupState>(
              builder: (context, state) {
                return Scaffold(
                  body: TabBarView(
                    children: isZo
                        ? [
                            ZoScheduleTab(tabNum: 0),
                            ZoScheduleTab(tabNum: 1),
                            ZoScheduleTab(tabNum: 2),
                            ZoScheduleTab(tabNum: 3),
                          ]
                        : [
                            ScheduleTab(tabNum: 0),
                            ScheduleTab(tabNum: 1),
                          ],
                  ),
                  floatingActionButton: state is CurrentGroupLoaded
                      ? FloatingActionButton(
                          onPressed: () {
                            //TODO Кнопка добавления в избранное
                          },
                          child: const Icon(Icons.star_border),
                        )
                      : null,
                );
              },
            ),
          ),
          TabBar(
            tabs: isZo
                ? [
                    const Tab(text: '1 неделя'),
                    const Tab(text: '2 неделя'),
                    const Tab(text: '3 неделя'),
                    const Tab(text: '4 неделя'),
                  ]
                : [
                    Tab(text: '1 неделя $firstTabStar'),
                    Tab(text: '2 неделя $secondTabStar'),
                  ],
            labelColor: Colors.black87,
            labelStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class ScheduleTab extends Container {
  final int tabNum;

  final daysOfWeekList = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  ScheduleTab({super.key, required this.tabNum});

  @override
  Widget build(BuildContext context) {
    final currentState = BlocProvider.of<CurrentGroupCubit>(context).state;

    if (currentState is CurrentGroupInitial) {
      return Column(
        children: [
          Image.asset(
            'assets/arrowToGroups.png',
            height: 60,
          ),
          const Text(
            'Выберите группу',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Container(),
          ),
          const Text(
            'Текущая неделя выделена звездочкой',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    if (currentState is CurrentGroupLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentState is CurrentGroupLoaded) {
      final currentDay = Jiffy().dateTime.weekday - 1;
      final numOfDays = currentState.currentScheduleList.length == 12 ? 6 : 7;

      return ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: DayOfWeekCard(
              dayOfWeekIndex: index,
              scheduleList:
                  currentState.currentScheduleList[index + tabNum * numOfDays],
              isCurrentDay: index == currentDay,
              dayOfWeek: daysOfWeekList[index],
            ),
          );
        },
        itemCount: currentState.currentScheduleList.length == 12 ? 6 : 7,
      );
    }

    return const Center(child: Text('Ошибка загрузки'));
  }
}

class ZoScheduleTab extends Container {
  final int tabNum;

  ZoScheduleTab({super.key, required this.tabNum});

  @override
  Widget build(BuildContext context) {
    final currentState = BlocProvider.of<CurrentGroupCubit>(context).state;

    if (currentState is CurrentGroupInitial) {
      return Column(
        children: [
          Image.asset(
            'assets/arrowToGroups.png',
            height: 60,
          ),
          const Text(
            'Выберите группу',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      );
    }

    if (currentState is CurrentGroupLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentState is CurrentGroupLoaded) {
      final numOfDays = currentState.currentScheduleList.length == 12 ? 6 : 7;

      if (tabNum * numOfDays < currentState.currentScheduleList.length) {
        return ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: DayOfWeekCard(
                dayOfWeekIndex: index,
                scheduleList: currentState
                    .currentScheduleList[index + tabNum * numOfDays]
                    .skip(1)
                    .toList(),
                dayOfWeek: currentState
                    .currentScheduleList[index + tabNum * numOfDays][0],
              ),
            );
          },
          itemCount: numOfDays,
        );
      }

      return const Center(child: Text('На эту неделю отсутствует расписание'));
    }

    return const Center(child: Text('Ошибка загрузки'));
  }
}

/// Карточка дня недели с расписанием
///
/// [dayOfWeekIndex] нужен для определения, какая карочка будет раскрытой
///
/// [scheduleList] - лист с предметами текущего дня
///
/// [isCurrentDay] определяет, открыта ли карточка при загрузке расписания
///
/// [dayOfWeek] - название дня недели. Для заочки отдельное, иначе типовое
class DayOfWeekCard extends StatelessWidget {
  final int dayOfWeekIndex;
  final List<String> scheduleList;
  final bool isCurrentDay;
  final String dayOfWeek;

  final List<String> lessonTimeList = [
    '9:00\n10:35',
    '10:45\n12:20',
    '13:00\n14:35',
    '14:45\n16:20',
    '16:25\n18:00',
    '18:05\n19:40',
    '19:45\n21:20',
  ];

  DayOfWeekCard({
    super.key,
    required this.dayOfWeekIndex,
    required this.scheduleList,
    this.isCurrentDay = false,
    required this.dayOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    /// номер пары. начинается с -1 потому что в цикле добавления пары
    /// в карточку первым действием он плюсуется. Так как это значение
    /// также используется как индекс массива
    int lessonNumber = -1;

    int currentLesson = -1;
    bool isCurrentDayOpened = false;

    final currentState = BlocProvider.of<CurrentGroupCubit>(context).state;
    if (currentState is CurrentGroupLoaded) {
      isCurrentDayOpened = currentState.openedDayIndex == dayOfWeekIndex;
      currentLesson = currentState.currentLesson;
    }

    return Card(
      child: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              BlocProvider.of<CurrentGroupCubit>(context)
                  .changeOpenedDay(dayOfWeekIndex);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              minimumSize: const Size(400, 50),
            ),
            child: Text(
              dayOfWeek,
              style: const TextStyle(fontSize: 24, color: Colors.black87),
            ),
          ),

          /// Если день открыт и лист расписания не переполнен,
          /// то создаем виджеты для предметов
          isCurrentDayOpened
              ? scheduleList.length <= lessonTimeList.length
                  ? Column(
                      children: scheduleList.map((String lesson) {
                        lessonNumber++;

                        return LessonSection(
                          lessonNumber: lessonNumber + 1,
                          lessonTime: lessonTimeList[lessonNumber],
                          lesson: lesson,
                          isCurrentLesson:
                              isCurrentDay && lessonNumber == currentLesson,
                        );
                      }).toList(),
                    )
                  : const Text(
                      'Ошибка загрузки расписания. Лист расписания переполнен')
              : const SizedBox(),
          isCurrentDayOpened ? const SizedBox(height: 10) : const SizedBox()
        ],
      ),
    );
  }
}

/// Строка пары с номером и временем
class LessonSection extends StatelessWidget {
  final String lesson;
  final String lessonTime;
  final int lessonNumber;
  final bool isCurrentLesson;

  const LessonSection({
    super.key,
    required this.lessonNumber,
    required this.lessonTime,
    required this.lesson,
    this.isCurrentLesson = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        children: [
          const Divider(),
          IntrinsicHeight(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Center(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: isCurrentLesson
                              ? const Color(0xFFFA8D62)
                              : const Color(0xFF6EB5C0),
                          size: 30,
                        ),
                        Text(
                          lessonNumber.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(),
                Text(
                  lessonTime,
                  textAlign: TextAlign.center,
                ),
                const VerticalDivider(),
                Expanded(
                  child: Text(
                    lesson,
                    style: isCurrentLesson
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
