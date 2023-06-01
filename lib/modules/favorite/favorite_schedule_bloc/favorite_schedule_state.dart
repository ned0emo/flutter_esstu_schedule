part of 'favorite_schedule_bloc.dart';

@immutable
abstract class FavoriteScheduleState {}

class FavoriteScheduleInitial extends FavoriteScheduleState {}

class FavoriteScheduleError extends FavoriteScheduleState {
  final String message;

  FavoriteScheduleError(this.message);
}

class FavoriteScheduleLoading extends FavoriteScheduleState {}

class FavoriteScheduleLoaded extends FavoriteScheduleState {
  final String currentScheduleName;
  final List<List<String>> scheduleList;
  final String scheduleType;
  final int openedDayIndex;
  final int currentLesson;
  final int weekNumber;

  final String? link1;
  final String? link2;
  final List<String>? customDaysOfWeek;

  FavoriteScheduleLoaded({
    required this.currentScheduleName,
    required this.scheduleList,
    required this.scheduleType,
    required this.openedDayIndex,
    required this.currentLesson,
    required this.weekNumber,
    this.link1,
    this.link2,
    this.customDaysOfWeek,
  });

  FavoriteScheduleLoaded copyWith({
    String? currentScheduleName,
    List<List<String>>? scheduleList,
    String? scheduleType,
    int? openedDayIndex,
    int? currentLesson,
    int? weekNumber,
    String? link1,
    String? link2,
    List<String>? customDaysOfWeek,
  }) {
    return FavoriteScheduleLoaded(
      currentScheduleName: currentScheduleName ?? this.currentScheduleName,
      scheduleList: scheduleList ?? this.scheduleList,
      scheduleType: scheduleType ?? this.scheduleType,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
      weekNumber: weekNumber ?? this.weekNumber,
      link1: link1 ?? this.link1,
      link2: link2 ?? this.link2,
      customDaysOfWeek: customDaysOfWeek ?? this.customDaysOfWeek,
    );
  }

  int get numOfWeeks =>
      scheduleList.length == 12 ? 2 : scheduleList.length ~/ 7;

  int get numOfDays => scheduleList.length == 12 ? 6 : 7;

  bool get isZo => scheduleList.length == 12 ? false : true;
}
