part of 'custom_timetable_bloc.dart';

@immutable
sealed class CustomTimetableEvent {}

final class InitCustomTimetable extends CustomTimetableEvent {
  final String name;
  final String type;

  InitCustomTimetable({required this.name, required this.type});
}

final class AddWeek extends CustomTimetableEvent {}

final class RemoveWeek extends CustomTimetableEvent {
  final int weekIndex;

  RemoveWeek({required this.weekIndex});
}

final class AddDayOfWeek extends CustomTimetableEvent {
  final WeekModel week;
  final int dayOfWeekIndex;
  final String? dayOfWeekDate;

  AddDayOfWeek(
      {required this.week, required this.dayOfWeekIndex, this.dayOfWeekDate});
}

final class RemoveDayOfWeek extends CustomTimetableEvent {
  final WeekModel week;
  final int dayOfWeekIndex;

  RemoveDayOfWeek({required this.week, required this.dayOfWeekIndex});
}

final class AddLesson extends CustomTimetableEvent {
  final DayOfWeekModel dayOfWeek;
  final int lessonIndex;

  AddLesson({required this.lessonIndex, required this.dayOfWeek});
}

final class RemoveLesson extends CustomTimetableEvent {
  final DayOfWeekModel dayOfWeek;
  final int lessonIndex;

  RemoveLesson({required this.dayOfWeek, required this.lessonIndex});
}
