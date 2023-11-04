import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:schedule/core/models/lesson_model.dart';

class DayOfWeekModel {
  final int dayOfWeekNumber;
  final String dayOfWeekName;
  final List<Lesson> lessons;
  final String? dayOfWeekDate;

  DayOfWeekModel({
    required this.dayOfWeekNumber,
    required this.dayOfWeekName,
    required this.lessons,
    this.dayOfWeekDate,
  });

  @override
  toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'dayOfWeekNumber': dayOfWeekNumber,
        'dayOfWeekName': dayOfWeekName,
        'dayOfWeekDate': dayOfWeekDate,
        'lessons': lessons,
      };

  static DayOfWeekModel fromJson(Map<String, dynamic> json) {
    List<Lesson> lessonsFromJson(List<dynamic> list) {
      final List<Lesson> newList = [];
      for (var lesson in list) {
        newList.add(Lesson.fromJson(lesson));
      }
      return newList;
    }

    return DayOfWeekModel(
      dayOfWeekNumber: json['dayOfWeekNumber'],
      dayOfWeekName: json['dayOfWeekName'],
      dayOfWeekDate: json['dayOfWeekDate'],
      lessons: lessonsFromJson(json['lessons']),
    );
  }

  int get dayOfWeekIndex => dayOfWeekNumber - 1;

  void updateLesson(Lesson lesson) {
    final sameLesson = lessons.firstWhereOrNull(
        (element) => element.lessonNumber == lesson.lessonNumber);

    if (sameLesson != null) {
      if (sameLesson.fullLesson.length > lesson.fullLesson.length) {
        return;
      }
      lessons[lessons.indexOf(sameLesson)] = lesson;
      return;
    }

    lessons.add(lesson);
    lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
  }

  Lesson lessonAt(int index) => lessons[index];
}
