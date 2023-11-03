part of 'search_schedule_bloc.dart';

@immutable
abstract class SearchScheduleState {
  final String? appBarTitle;

  const SearchScheduleState({this.appBarTitle});
}

class SearchScheduleInitial extends SearchScheduleState {}

class SearchScheduleLoading extends SearchScheduleState {
  const SearchScheduleLoading({String? appBarName})
      : super(appBarTitle: appBarName);
}

class SearchScheduleLoaded extends SearchScheduleState {
  final ScheduleModel scheduleModel;

  const SearchScheduleLoaded({
    required this.scheduleModel,
    String? appBarName,
  }) : super(appBarTitle: appBarName);
}

class SearchScheduleError extends SearchScheduleState {
  final String message;

  const SearchScheduleError(this.message);
}
