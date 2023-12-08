import 'package:flutter/material.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/static/schedule_time_data.dart';

class LessonSection extends StatelessWidget {
  final Lesson? lesson;
  final bool isCurrentLesson;
  final int lessonNumber;

  const LessonSection({
    super.key,
    required this.lesson,
    required this.isCurrentLesson,
    this.lessonNumber = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _lessonNumberSection(),
        Card(
          child: lesson != null
              ? _existingLesson()
              : SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 5.0),
                    child: Text(
                      'Занятие отсутствует',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrentLesson ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _lessonNumberSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Text('${lesson?.lessonNumber ?? lessonNumber}.',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 5, child: Divider(thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            child: Text(
              ScheduleTimeData
                  .lessonTimeList[(lesson?.lessonNumber ?? lessonNumber) - 1],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Expanded(child: Divider(thickness: 1)),
          if (isCurrentLesson)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: .0, horizontal: 5.0),
              child: Text(
                'Сейчас',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _existingLesson() {
    return Column(
      children: lesson!.lessonData!
          .map(
            (lessonPart) => IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    decoration: BoxDecoration(
                      color: _lessonColor(lessonPart[Lesson.type].toString()),
                      borderRadius: lesson!.lessonData!.length < 2
                          ? const BorderRadius.horizontal(
                              left: Radius.circular(4),
                            )
                          : lesson!.lessonData!.first == lessonPart
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                )
                              : lesson!.lessonData!.last == lessonPart
                                  ? const BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                    )
                                  : null,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lessonPart[Lesson.type].toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              lessonPart[Lesson.title].toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isCurrentLesson ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                          if (lessonPart[Lesson.teachers]?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lessonPart[Lesson.teachers]!.contains(',')
                                        ? 'Преподаватели: '
                                        : 'Преподаватель: ',
                                  ),
                                  Expanded(
                                      child: Text(
                                    lessonPart[Lesson.teachers]!,
                                  )),
                                ],
                              ),
                            ),
                          if (lessonPart[Lesson.classrooms]?.isNotEmpty ??
                              false)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lessonPart[Lesson.classrooms]!.contains(',')
                                        ? 'Аудитории: '
                                        : 'Аудитория: ',
                                  ),
                                  Expanded(
                                      child: Text(
                                    lessonPart[Lesson.classrooms]!,
                                  )),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Color _lessonColor(String lessonType) {
    switch (lessonType) {
      case 'Лекция':
        return const Color.fromARGB(255, 255, 129, 118);
      case 'Практика':
        return const Color.fromARGB(255, 145, 108, 255);
      case 'Лабораторная':
        return const Color.fromARGB(255, 255, 231, 112);
      case 'Физическая культура':
        return const Color.fromARGB(255, 118, 255, 150);
      case 'Экзамен':
        return const Color.fromARGB(255, 255, 157, 239);
      default:
        return const Color.fromARGB(255, 255, 148, 41);
    }
  }
}
