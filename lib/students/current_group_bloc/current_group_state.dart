part of 'current_group_cubit.dart';

abstract class CurrentGroupState {}

class CurrentGroupInitial extends CurrentGroupState {}

class CurrentGroupLoading extends CurrentGroupState {}

class CurrentGroupLoaded extends CurrentGroupState {
  final List<List<String>> currentScheduleList;
  final String scheduleFullLink;
  final int openedDayIndex;
  final int currentLesson;

  CurrentGroupLoaded({
    required this.currentScheduleList,
    required this.scheduleFullLink,
    required this.openedDayIndex,
    required this.currentLesson
  });
}

class CurrentGroupLoadingError extends CurrentGroupState {}
