part of 'favorite_schedule_bloc.dart';

@immutable
abstract class FavoriteScheduleEvent {}

class LoadFavoriteSchedule extends FavoriteScheduleEvent {
  final String scheduleName;

  LoadFavoriteSchedule(this.scheduleName);
}

class ChangeOpenedDay extends FavoriteScheduleEvent {
  final int dayIndex;

  ChangeOpenedDay(this.dayIndex);
}
