part of 'current_group_cubit.dart';

abstract class CurrentGroupState {}

class CurrentGroupInitial extends CurrentGroupState {}

class CurrentGroupLoading extends CurrentGroupState {}

class CurrentGroupLoaded extends CurrentGroupState {
  final List<List<String>> currentScheduleList;
  final String scheduleFullLink;
  final int openedDayIndex;
  final int currentLesson;
  final int weekNumber;

  final bool isZo;
  final List<String>? daysOfWeekList;


  CurrentGroupLoaded({
    required this.currentScheduleList,
    required this.scheduleFullLink,
    required this.openedDayIndex,
    required this.currentLesson,
    required this.weekNumber,
    this.isZo = false,
    this.daysOfWeekList,
  });

  int get numOfWeeks =>
      currentScheduleList.length == 12 ? 2 : currentScheduleList.length ~/ 7;

  int get starIndex => isZo ? -1 : weekNumber;

  int get initialIndex => isZo ? 0 : weekNumber;
}

class CurrentGroupLoadingError extends CurrentGroupState {}
