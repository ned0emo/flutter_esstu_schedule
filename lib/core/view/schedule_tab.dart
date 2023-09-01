import 'package:flutter/material.dart';
import 'package:schedule/core/schedule_time_data.dart';

class ScheduleTab extends StatefulWidget {
  final int tabNum;
  final String scheduleName;
  final bool hideSchedule;
  final bool showLessonColor;

  final List<List<String>> scheduleList;
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
      for (String lesson in scheduleList[i]) {
        if (lesson.length > 5) {
          return true;
        }
      }
    }
    return false;
  }
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
    if (!widget.isScheduleExist) {
      return const Center(child: Text('Расписание отсутствует'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 40),
      itemBuilder: (context, index) {
        if (widget.hideSchedule &&
            widget.scheduleList[index + widget.tabNum * widget.numOfDays]
                    .join()
                    .length <
                10) {
          return const SizedBox();
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
              style: const TextStyle(fontSize: 24),
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

                              return lesson.length < 5 && widget.hideSchedule
                                  ? const SizedBox()
                                  : _lessonSection(
                                      lessonNumber: lessonNumber + 1,
                                      lessonTime: ScheduleTimeData
                                          .lessonTimeList[lessonNumber],
                                      lesson: _beautyLesson(lesson),
                                      teachers: _teacherNames(lesson),
                                      lessonType: _lessonType(lesson),
                                      isCurrentLesson: !widget.isZo &&
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (lesson.length > 5)
                        Row(
                          children: [
                            Text(
                              lessonType,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: widget.showLessonColor ? Container(
                                height: 8,
                                decoration: BoxDecoration(
                                    color: _lessonColor(lessonType),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4))),
                              ) : const SizedBox(),
                            ),
                            if (isCurrentLesson)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: Text(
                                  'Сейчас',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                          ],
                        ),
                      Text(
                        lesson,
                        style: isCurrentLesson
                            ? const TextStyle(fontWeight: FontWeight.bold)
                            : null,
                      ),
                      if (lesson.length > 5 && teachers.isNotEmpty)
                        Text('\n${teachers.join(', ')}')
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

  String _beautyLesson(String lesson) {
    return lesson
        //приписки аудиторий
        .replaceAll(RegExp(r'и/д|д/кл|д/к|н/х'), '')
        //препод
        .replaceAll(
            RegExp(
                r'[А-Я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я]+\s+[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.'),
            '')
        //тип занятия
        .replaceAll(
            RegExp(r'лек\.|пр\.|лаб\.|ЭК по ФКС|Физическая культура|экз\.'), '')
        //остатки аудитории в расписании аудиторий
        .replaceAll('а. ', '')
        //длинные пробелы
        .replaceAll(RegExp(r'\s+'), ' ')
        //много точек
        .replaceAll(RegExp(r'\.+'), '.')
        .trim();

    //final index = newLesson.indexOf(RegExp(r'[А-Я]'));
    //return index < 0 ? newLesson : newLesson.substring(index);
  }

  List<String> _teacherNames(String lesson) {
    return RegExp(
            r'[А-Я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я]+\s+[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.')
        .allMatches(lesson)
        .map((e) => e[0] ?? '')
        .toList();
  }

  String _lessonType(String lesson) {
    final lType =
        RegExp(r'лек\.|пр\.|лаб\.|ЭК по ФКС|Физическая культура|экз\.')
            .firstMatch(lesson)?[0];
    switch (lType) {
      case 'лек.':
        return 'Лекция';
      case 'пр.':
        return 'Практика';
      case 'лаб.':
        return 'Лабораторная';
      case 'ЭК по ФКС':
        return 'Физическая культура';
      case 'Физическая культура':
        return 'Физическая культура';
      case 'экз.':
        return 'Экзамен';
      default:
        return 'Другое';
    }
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
        return const Color.fromARGB(255, 253, 200, 81);
    }
  }
}
