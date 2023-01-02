part of 'current_group_cubit.dart';

abstract class CurrentGroupState {}

class CurrentGroupInitial extends CurrentGroupState {}

class CurrentGroupLoading extends CurrentGroupState {}

class CurrentGroupLoaded extends CurrentGroupState {
  final List<List<String>> currentScheduleList;
  final String scheduleFullLink;

  CurrentGroupLoaded({
    required this.currentScheduleList,
    required this.scheduleFullLink,
  });
}

class CurrentGroupLoadingError extends CurrentGroupState {}
