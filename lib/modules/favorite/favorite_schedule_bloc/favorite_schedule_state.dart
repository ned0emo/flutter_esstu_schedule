part of 'favorite_schedule_bloc.dart';

@immutable
abstract class FavoriteScheduleState {
  final daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];
}

class FavoriteScheduleInitial extends FavoriteScheduleState {}

class FavoriteScheduleError extends FavoriteScheduleState {
  final String message;

  FavoriteScheduleError(this.message);
}

class FavoriteScheduleLoading extends FavoriteScheduleState {}

class FavoriteScheduleLoaded extends FavoriteScheduleState {
  final String currentScheduleName;
  final List<List<String>> scheduleList;
  final int openedDayIndex;
  final int currentLesson;
  final int weekNumber;

  FavoriteScheduleLoaded({
    required this.currentScheduleName,
    required this.scheduleList,
    required this.openedDayIndex,
    required this.currentLesson,
    required this.weekNumber,
  });

  FavoriteScheduleLoaded copyWith({
    String? currentScheduleName,
    List<List<String>>? scheduleList,
    int? openedDayIndex,
    int? currentLesson,
    int? weekNumber,
  }) {
    return FavoriteScheduleLoaded(
      currentScheduleName: currentScheduleName ?? this.currentScheduleName,
      scheduleList: scheduleList ?? this.scheduleList,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
      weekNumber: weekNumber ?? this.weekNumber,
    );
  }
}
