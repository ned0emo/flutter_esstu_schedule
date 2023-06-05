part of 'search_schedule_bloc.dart';

@immutable
abstract class SearchScheduleState {}

class SearchScheduleInitial extends SearchScheduleState {}

class SearchScheduleLoading extends SearchScheduleState {}

class SearchScheduleLoaded extends SearchScheduleState {
  final String scheduleName;
  final List<List<String>> scheduleList;
  final int openedDayIndex;
  final int currentLesson;
  final int weekNumber;

  final String? link1;
  final String? link2;
  final List<String>? customDaysOfWeek;

  SearchScheduleLoaded({
    required this.scheduleName,
    required this.scheduleList,
    required this.openedDayIndex,
    required this.currentLesson,
    required this.weekNumber,
    this.link1,
    this.link2,
    this.customDaysOfWeek,
  });

  SearchScheduleLoaded copyWith({
    String? scheduleName,
    List<List<String>>? scheduleList,
    int? openedDayIndex,
    int? currentLesson,
    int? weekNumber,
    String? link1,
    String? link2,
    List<String>? customDaysOfWeek,
  }) {
    return SearchScheduleLoaded(
      scheduleName: scheduleName ?? this.scheduleName,
      scheduleList: scheduleList ?? this.scheduleList,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
      weekNumber: weekNumber ?? this.weekNumber,
      link1: link1 ?? this.link1,
      link2: link2 ?? this.link2,
      customDaysOfWeek: customDaysOfWeek ?? this.customDaysOfWeek,
    );
  }
}

class SearchScheduleError extends SearchScheduleState{
  final String message;

  SearchScheduleError(this.message);
}
