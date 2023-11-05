part of 'current_group_bloc.dart';

@immutable
abstract class CurrentGroupState {}

class CurrentGroupInitial extends CurrentGroupState {}

class CurrentGroupLoading extends CurrentGroupState {}

class CurrentGroupLoaded extends CurrentGroupState {
  final String name;
  final ScheduleModel scheduleModel;
  final String? message;

  CurrentGroupLoaded({
    required this.name,
    required this.scheduleModel,
    this.message,
  });
}

class CurrentGroupError extends CurrentGroupState {
  final String message;

  CurrentGroupError(this.message);
}
