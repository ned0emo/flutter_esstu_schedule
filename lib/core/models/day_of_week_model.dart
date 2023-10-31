import 'package:collection/collection.dart';
import 'package:schedule/core/models/lesson_model.dart';

class DayOfWeekModel {
  final int dayOfWeekNumber;
  final String dayOfWeekName;
  final List<Lesson> lessons;

  DayOfWeekModel({
    required this.dayOfWeekNumber,
    required this.dayOfWeekName,
    required this.lessons,
  });

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

  Lesson at(int index) => lessons[index];
}
