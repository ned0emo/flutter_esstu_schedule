import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/core/schedule_time_data.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';

class DepartmentScheduleTab extends StatefulWidget {
  final int tabNum;

  const DepartmentScheduleTab({super.key, this.tabNum = 0});

  @override
  State<StatefulWidget> createState() => _DepartmentScheduleTabState();
}

class _DepartmentScheduleTabState extends State<DepartmentScheduleTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        if (state is DepartmentLoading || state is DepartmentInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DepartmentError) {
          return Center(child: Text(state.message));
        }

        if (state is DepartmentLoaded) {
          if (state.currentTeacher != null) {
            Modular.get<FavoriteButtonBloc>().add(CheckSchedule(
              name: state.currentTeacher!,
              scheduleType: ScheduleType.teacher,
            ));
          }

          final currentDay = Jiffy().dateTime.weekday - 1;

          return ListView.builder(
            itemBuilder: (context, index) {
              String? dayOfWeek;
              dayOfWeek = ScheduleTimeData.daysOfWeek[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _dayOfWeekCard(
                  index,
                  state.teachersScheduleMap[state.currentTeacher]![
                      index + widget.tabNum * 6],
                  index == currentDay,
                  dayOfWeek,
                  context,
                ),
              );
            },
            itemCount: 6,
          );
        }

        return const Center(child: Text('Неизвестная ошибка'));
      },
    );
  }

  Widget _dayOfWeekCard(int currentCardIndex, List<String> scheduleList,
      bool isCurrentDay, String dayOfWeek, BuildContext context) {
    /// номер пары. начинается с -1 потому что в цикле добавления пары
    /// в карточку первым действием он плюсуется. Так как это значение
    /// также используется как индекс массива
    int lessonNumber = -1;

    int currentLesson = -1;
    bool isCurrentDayOpened = false;

    final currentState = BlocProvider.of<DepartmentBloc>(context).state;
    if (currentState is DepartmentLoaded) {
      isCurrentDayOpened = currentState.openedDayIndex == currentCardIndex;
      currentLesson = currentState.currentLesson;
    }

    /// Карточка дня недели с расписанием
    ///
    /// [dayOfWeekIndex] нужен для определения, какая карочка будет раскрытой
    ///
    /// [scheduleList] - лист с предметами текущего дня
    ///
    /// [isCurrentDay] определяет, открыта ли карточка при загрузке расписания
    ///
    /// [dayOfWeek] - название дня недели
    return Card(
      child: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              BlocProvider.of<DepartmentBloc>(context)
                  .add(ChangeOpenedDay(currentCardIndex));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              minimumSize: const Size(400, 60),
            ),
            child: Text(
              dayOfWeek,
              style: const TextStyle(fontSize: 24, color: Colors.black87),
            ),
          ),

          /// Если день открыт и лист расписания не переполнен,
          /// то создаем виджеты для предметов
          isCurrentDayOpened
              ? scheduleList.length <= ScheduleTimeData.lessonTimeList.length
                  ? Column(
                      children: scheduleList.map(
                            (String lesson) {
                              lessonNumber++;

                              return _lessonSection(
                                lessonNumber + 1,
                                ScheduleTimeData.lessonTimeList[lessonNumber],
                                lesson,
                                isCurrentDay && lessonNumber == currentLesson,
                              );
                            },
                          ).toList() +
                          [const SizedBox(height: 10)],
                    )
                  : const Text(
                      'Ошибка загрузки расписания. Лист расписания переполнен')
              : const SizedBox(),
        ],
      ),
    );
  }

  /// Строка пары с номером и временем
  Widget _lessonSection(int lessonNumber, String lessonTime, String lesson,
      bool isCurrentLesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const Divider(),

          ///Для вертиклаьных разделителей
          IntrinsicHeight(
            child: Row(
              children: [
                Center(
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
                const VerticalDivider(),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      lessonTime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
