import 'package:flutter/material.dart';
import 'package:schedule/core/schedule_time_data.dart';

class ScheduleTab extends StatefulWidget {
  final int tabNum;
  final String scheduleName;

  //final String scheduleType;
  final List<List<String>> scheduleList;

  //final int openedDayIndex;
  //final int currentLesson;
  //final int weekNumber;

  //final String? link1;
  //final String? link2;
  final List<String>? customDaysOfWeek;

  //final bool isNeedUpdate;

  const ScheduleTab({
    super.key,
    required this.tabNum,
    required this.scheduleName,
    required this.scheduleList,
    this.customDaysOfWeek,
  });

  @override
  State<StatefulWidget> createState() => _ScheduleTabState();

  int get numOfDays => scheduleList.length == 12 ? 6 : 7;

  bool get isZo => scheduleList.length == 12 ? false : true;
}

class _ScheduleTabState extends State<ScheduleTab> {
  late int openedDayIndex;
  late int currentLesson;
  late int weekNumber;
  late int currentDay;

  @override
  void initState() {
    openedDayIndex = ScheduleTimeData.getCurrentDayOfWeek();
    currentDay = ScheduleTimeData.getCurrentDayOfWeek();
    currentLesson = ScheduleTimeData.getCurrentLessonNumber();
    weekNumber = ScheduleTimeData.getCurrentWeekNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        String dayOfWeek;

        if (widget.customDaysOfWeek == null) {
          dayOfWeek = ScheduleTimeData.daysOfWeek[index];
        } else {
          if (index + widget.numOfDays * widget.tabNum <
              widget.customDaysOfWeek!.length) {
            dayOfWeek = widget
                .customDaysOfWeek![index + widget.numOfDays * widget.tabNum];
          } else {
            dayOfWeek = 'Ошибка определения';
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _dayOfWeekCard(
            index,
            widget.scheduleList[index + widget.tabNum * widget.numOfDays],
            index == currentDay,
            dayOfWeek,
            context,
          ),
        );
      },
      itemCount: widget.numOfDays,
    );
  }

  Widget _dayOfWeekCard(
    int currentCardIndex,
    List<String> scheduleList,
    bool isCurrentDay,
    String dayOfWeek,
    BuildContext context,
  ) {
    /// номер пары. начинается с -1 потому что в цикле добавления пары
    /// в карточку первым действием он плюсуется. Так как это значение
    /// также используется как индекс массива
    int lessonNumber = -1;

    bool isCurrentDayOpened = openedDayIndex == currentCardIndex;

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
              setState(() {
                openedDayIndex = currentCardIndex;
              });
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
                                !widget.isZo &&
                                    isCurrentDay &&
                                    weekNumber == widget.tabNum &&
                                    lessonNumber == currentLesson,
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
