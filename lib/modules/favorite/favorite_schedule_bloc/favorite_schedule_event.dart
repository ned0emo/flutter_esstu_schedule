part of 'favorite_schedule_bloc.dart';

@immutable
abstract class FavoriteScheduleEvent {}

class LoadFavoriteSchedule extends FavoriteScheduleEvent {
  final String scheduleFileName;
  final bool isNeedUpdate;

  LoadFavoriteSchedule(this.scheduleFileName, {this.isNeedUpdate = false});
}

class ChangeOpenedDay extends FavoriteScheduleEvent {
  final int dayIndex;

  ChangeOpenedDay(this.dayIndex);
}
