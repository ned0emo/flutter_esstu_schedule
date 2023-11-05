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
  final ScheduleModel scheduleModel;

  final bool isNeedUpdate;
  final bool isFromMainPage;

  FavoriteScheduleLoaded({
    required this.scheduleModel,
    this.isNeedUpdate = false,
    this.isFromMainPage = false,
  });

  String get getFileName => '${scheduleModel.type}|${scheduleModel.name}';
}
