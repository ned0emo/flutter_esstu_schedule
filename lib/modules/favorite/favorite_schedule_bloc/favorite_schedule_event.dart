part of 'favorite_schedule_bloc.dart';

@immutable
abstract class FavoriteScheduleEvent {}

class LoadFavoriteSchedule extends FavoriteScheduleEvent {
  final String scheduleFileName;
  final bool isNeedUpdate;
  final bool isFromMainPage;

  LoadFavoriteSchedule(
    this.scheduleFileName, {
    this.isNeedUpdate = false,
    this.isFromMainPage = false,
  });
}

class OpenMainFavSchedule extends FavoriteScheduleEvent {}

class ResetSchedule extends FavoriteScheduleEvent {}
