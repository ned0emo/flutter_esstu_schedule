import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/static/schedule_time_data.dart';

class ScheduleTab extends StatefulWidget {
  final int tabNum;
  final String scheduleName;
  final bool hideSchedule;
  final bool showLessonColor;

  final List<List<Lesson>> scheduleList;
  final List<String>? customDaysOfWeek;

  const ScheduleTab({
    super.key,
    required this.tabNum,
    required this.scheduleName,
    required this.hideSchedule,
    required this.showLessonColor,
    required this.scheduleList,
    this.customDaysOfWeek,
  });

  @override
  State<StatefulWidget> createState() => _ScheduleTabState();

  int get numOfDays => scheduleList.length == 12 ? 6 : 7;

  bool get isZo => scheduleList.length == 12 ? false : true;

  bool get isScheduleExist {
    if (!hideSchedule) return true;

    int border = tabNum * numOfDays;
    for (int i = border; i < border + numOfDays; i++) {
      for (var lesson in scheduleList[i]) {
        if (!lesson.isEmpty) return true;
      }
    }
    return false;
  }
}

class _ScheduleTabState extends State<ScheduleTab>
    with AutomaticKeepAliveClientMixin {
  late int openedDayIndex;
  late int currentLesson;
  late int weekNumber;
  late int currentDay;
  late ScrollController scrollController;

  @override
  void initState() {
    openedDayIndex = widget.isZo ? -1 : ScheduleTimeData.getCurrentDayOfWeek();
    currentDay = ScheduleTimeData.getCurrentDayOfWeek();
    currentLesson = ScheduleTimeData.getCurrentLessonIndex();
    weekNumber = ScheduleTimeData.getCurrentWeekIndex();
    scrollController = ScrollController();

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.isScheduleExist) {
      return const Center(child: Text('Расписание отсутствует'));
    }

    int fix = 0;

    return ListView.builder(
      cacheExtent: 1000,
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 40),
      itemBuilder: (context, index) {
        if (widget.hideSchedule) {
          bool isEmpty = true;
          for (var lesson in widget
              .scheduleList[index + widget.tabNum * widget.numOfDays]) {
            if (!lesson.isEmpty) {
              isEmpty = false;
              break;
            }
          }
          if (isEmpty) {
            fix++;
            return const SizedBox();
          }
        }

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

        return _dayOfWeekCard(
          index,
          index - fix,
          widget.scheduleList[index + widget.tabNum * widget.numOfDays],
          index == currentDay,
          dayOfWeek,
          context,
        );
      },
      itemCount: widget.numOfDays,
    );
  }

  Widget _dayOfWeekCard(
    int currentCardIndex,
    int absoluteCardIndex,
    List<Lesson> scheduleList,
    bool isCurrentDay,
    String dayOfWeek,
    BuildContext context,
  ) {
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
                openedDayIndex = isCurrentDayOpened ? -1 : currentCardIndex;
              });

              if (!isCurrentDayOpened) {
                scrollController.animateTo(
                    min(68.0 * absoluteCardIndex + 10,
                        scrollController.position.maxScrollExtent),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear);
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              minimumSize: const Size(400, 60),
            ),
            child: Text(
              dayOfWeek,
              style: const TextStyle(fontSize: 24),
            ),
          ),

          /// Если день открыт и лист расписания не переполнен,
          /// то создаем виджеты для предметов
          isCurrentDayOpened
              ? scheduleList.length <= ScheduleTimeData.lessonTimeList.length
                  ? Column(
                      children: scheduleList.map(
                            (Lesson lesson) {
                              return widget.hideSchedule && lesson.isEmpty
                                  ? const SizedBox()
                                  : _lessonSection(
                                      lessonNumber: lesson.lessonNumber,
                                      lessonTime: ScheduleTimeData
                                          .lessonTimeList[lesson.lessonNumber - 1],
                                      lesson: lesson.title,
                                      teachers: lesson.teachers,
                                      lessonType: lesson.type,
                                      isCurrentLesson: !widget.isZo &&
                                          isCurrentDay &&
                                          weekNumber == widget.tabNum &&
                                          lesson.lessonNumber - 1 == currentLesson,
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
  Widget _lessonSection({
    required int lessonNumber,
    required String lessonTime,
    required String lesson,
    required List<String> teachers,
    required String lessonType,
    required bool isCurrentLesson,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const Divider(),

          ///Для вертиклаьных разделителей
          IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: isCurrentLesson
                              ? const Color(0xFFFA8D62)
                              : Theme.of(context)
                                  .colorScheme
                                  .secondary, // const Color(0xFF6EB5C0),
                          size: 30,
                        ),
                        Text(
                          lessonNumber.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (lesson.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              lessonType,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: widget.showLessonColor
                                  ? Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: _lessonColor(lessonType),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4))),
                                    )
                                  : const SizedBox(),
                            ),
                            if (isCurrentLesson)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: Text(
                                  'Сейчас',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      if (lesson.isNotEmpty) const SizedBox(height: 10),
                      Text(
                        lesson,
                        style: isCurrentLesson
                            ? const TextStyle(fontWeight: FontWeight.bold)
                            : null,
                      ),
                      if (lesson.isNotEmpty && teachers.isNotEmpty)
                        const SizedBox(height: 10),
                      if (lesson.isNotEmpty && teachers.isNotEmpty)
                        Text(teachers.join(', '))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _lessonColor(String lessonType) {
    switch (lessonType) {
      case 'Лекция':
        return const Color.fromARGB(255, 255, 129, 118);
      case 'Практика':
        return const Color.fromARGB(255, 88, 209, 255);
      case 'Лабораторная':
        return const Color.fromARGB(255, 255, 231, 112);
      case 'Физическая культура':
        return const Color.fromARGB(255, 118, 255, 150);
      case 'Экзамен':
        return const Color.fromARGB(255, 255, 157, 239);
      default:
        return const Color.fromARGB(255, 255, 190, 41);
    }
  }
}
