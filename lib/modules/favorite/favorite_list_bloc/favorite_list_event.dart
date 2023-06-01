part of 'favorite_list_bloc.dart';

@immutable
abstract class FavoriteListEvent {}

class LoadFavoriteList extends FavoriteListEvent {}

class ClearAllSchedule extends FavoriteListEvent {}

class DeleteScheduleFromList extends FavoriteListEvent {
  final String scheduleName;
  final String scheduleType;

  DeleteScheduleFromList(this.scheduleName, this.scheduleType);
}
