import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/models/week_model.dart';

class ScheduleModel {
  final String name;
  final String type;
  final String? link1;
  final String? link2;

  final List<WeekModel> weeks;

  ScheduleModel({
    required this.name,
    required this.type,
    required this.weeks,
    this.link1,
    this.link2,
  });

  /// Если [weekIndex] равен длине массива, добавит неделю.
  /// Не обновляет, если новое название короче
  void updateWeek(
    int weekIndex,
    int dayOfWeekIndex,
    int lessonIndex,
    Lesson lesson, {
    String? dayOfWeekDate,
  }) {
    if (weekIndex >= weeks.length) {
      for (int i = weeks.length; i <= weekIndex; i++) {
        weeks.add(WeekModel(weekNumber: weekIndex + 1, daysOfWeek: []));
      }
    }

    weeks[weekIndex]
        .updateDayOfWeek(dayOfWeekIndex, lesson, dayOfWeekDate: dayOfWeekDate);
  }

  /// Если [weekIndex] за пределами массива, выдаст исключение
  Lesson? getLesson(int weekIndex, int dayOfWeekIndex, int lessonIndex) {
    return weeks[weekIndex].at(dayOfWeekIndex).at(lessonIndex);
  }

  bool get isEmpty => weeks.isEmpty;

  bool get isNotEmpty => weeks.isNotEmpty;

  int get numOfWeeks => weeks.length;

  /// Индекс дня недели для вкладки с учетом возможного отсутствия некоторых
  /// дней недели. [weekIndex] - номер недели, в которой ищем день.
  /// [dayOfWeekIndex] - индекс дня недели с ScheduleTimeData.
  /// Если индекс не найден, возвращает 0
  int dayOfWeekByAbsoluteIndex(int weekIndex, int dayOfWeekIndex) =>
      weeks[weekIndex].dayOfWeekByAbsoluteIndex(dayOfWeekIndex);

  int weekLength(int weekIndex) => weeks[weekIndex].weekLength;

  bool get isZo {
    for (var week in weeks) {
      for (var dayOfWeek in week.daysOfWeek) {
        if (dayOfWeek.dayOfWeekDate != null) return true;
      }
    }

    return false;
  }
}
