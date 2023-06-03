part of 'favorite_update_bloc.dart';

@immutable
abstract class FavoriteUpdateState {}

class FavoriteUpdateInitial extends FavoriteUpdateState {
  final String? message;

  FavoriteUpdateInitial({this.message});
}

class FavoriteScheduleUpdating extends FavoriteUpdateState {}

class FavoriteScheduleUpdated extends FavoriteUpdateState {
  final String scheduleName;
  final String scheduleType;
  final String message;

  FavoriteScheduleUpdated({
    required this.scheduleName,
    required this.scheduleType,
    required this.message,
  });

  String get fileName => '$scheduleType|$scheduleName';
}

class FavoriteScheduleUpdateError extends FavoriteUpdateState {
  final String message;

  FavoriteScheduleUpdateError(this.message);
}
