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
  final String scheduleName;
  final List<List<Lesson>> scheduleList;
  final String scheduleType;
  final int openedDayIndex;
  final int currentLesson;
  final int weekNumber;

  final String? link1;
  final String? link2;
  final List<String>? customDaysOfWeek;

  final bool isNeedUpdate;
  final bool isFromMainPage;

  FavoriteScheduleLoaded({
    required this.scheduleName,
    required this.scheduleList,
    required this.scheduleType,
    required this.openedDayIndex,
    required this.currentLesson,
    required this.weekNumber,
    this.link1,
    this.link2,
    this.customDaysOfWeek,
    this.isNeedUpdate = false,
    this.isFromMainPage = false,
  });

  FavoriteScheduleLoaded copyWith({
    String? scheduleName,
    List<List<Lesson>>? scheduleList,
    String? scheduleType,
    int? openedDayIndex,
    int? currentLesson,
    int? weekNumber,
    String? link1,
    String? link2,
    List<String>? customDaysOfWeek,
    bool? isNeedUpdate,
    bool? isFromMainPage,
  }) {
    return FavoriteScheduleLoaded(
      scheduleName: scheduleName ?? this.scheduleName,
      scheduleList: scheduleList ?? this.scheduleList,
      scheduleType: scheduleType ?? this.scheduleType,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
      weekNumber: weekNumber ?? this.weekNumber,
      link1: link1 ?? this.link1,
      link2: link2 ?? this.link2,
      customDaysOfWeek: customDaysOfWeek ?? this.customDaysOfWeek,
      isNeedUpdate: isNeedUpdate ?? false,
      isFromMainPage: isFromMainPage ?? this.isFromMainPage,
    );
  }

  int get numOfWeeks =>
      scheduleList.length == 12 ? 2 : scheduleList.length ~/ 7;

  int get numOfDays => scheduleList.length == 12 ? 6 : 7;

  bool get isZo => scheduleList.length == 12 ? false : true;

  String get getFileName => '$scheduleType|$scheduleName';
}
