import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule/students/all_groups_bloc/all_groups_cubit.dart';
import 'package:schedule/students/current_group_bloc/current_group_cubit.dart';

class StudentsView extends Container {
  StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    const daysOfWeekList = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];

    final allGroupsState = BlocProvider.of<AllGroupsCubit>(context).state;

    return DefaultTabController(
      length: 2,
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
                        onChanged: (value) {
                          BlocProvider.of<AllGroupsCubit>(context)
                              .selectGroup(value ?? '');

                          BlocProvider.of<CurrentGroupCubit>(context)
                              .loadCurrentGroup(allGroupsState.typeLink1 +
                                  (allGroupsState.linkGroupMap[value] ?? ''));
                        },
                      ),
                    ),
                  ],
                )
              : const Text('Ошибка загрузки'),
          Expanded(
            child: TabBarView(
              children: [
                BlocBuilder<CurrentGroupCubit, CurrentGroupState>(
                  builder: (context, state) {
                    if (state is CurrentGroupInitial) {
                      return const Center(
                        child: Text('Выберите группу'),
                      );
                    }

                    if (state is CurrentGroupLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CurrentGroupLoaded) {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: DayOfWeekCard(
                              dayOfWeekName: daysOfWeekList[index],
                              scheduleList: state.currentScheduleList[index],
                            ),
                          );
                        },
                        itemCount:
                            state.currentScheduleList.length == 12 ? 6 : 7,
                      );
                    }

                    return const Center(child: Text('Ошибка загрузки'));
                  },
                ),
                BlocBuilder<CurrentGroupCubit, CurrentGroupState>(
                  builder: (context, state) {
                    if (state is CurrentGroupLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CurrentGroupLoaded) {
                      final numOfDays =
                          state.currentScheduleList.length == 12 ? 6 : 7;

                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: DayOfWeekCard(
                              dayOfWeekName: daysOfWeekList[index],
                              scheduleList:
                                  state.currentScheduleList[index + numOfDays],
                            ),
                          );
                        },
                        itemCount: numOfDays,
                      );
                    }

                    return const Center(child: Text('Ошибка загрузки'));
                  },
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: '1 неделя'),
              Tab(text: '2 неделя'),
            ],
            labelColor: Colors.black87,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Карточка дня недели с расписанием
class DayOfWeekCard extends StatelessWidget {
  final String dayOfWeekName;
  final List<String> scheduleList;
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
    required this.dayOfWeekName,
    required this.scheduleList,
  });

  @override
  Widget build(BuildContext context) {
    /// номер пары. начинается с -1 потому что в цикле добавления пары
    /// в карточку первым действием он плюсуется. Так как это значение
    /// также используется как индекс массива
    int lessonNumber = -1;

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              dayOfWeekName,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          scheduleList.length <= lessonTimeList.length
              ? Column(
                  children: scheduleList.map((String lesson) {
                    lessonNumber++;
                    return LessonSection(
                      lessonNumber: lessonNumber + 1,
                      lessonTime: lessonTimeList[lessonNumber],
                      lesson: lesson,
                    );
                  }).toList(),
                )
              : const Text('Ошибка загрузки расписания'),
          const SizedBox(
            height: 10,
          ),
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
      //TODO Значение высоты для раскрытия/скрытия карточки. Мб переместить выше
      height: null,
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
                        const Icon(Icons.circle, color: Colors.grey,),
                        Text(lessonNumber.toString()),
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
                  child: Text(lesson),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
