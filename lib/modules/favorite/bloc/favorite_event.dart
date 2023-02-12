part of 'favorite_bloc.dart';

@immutable
abstract class FavoriteEvent {}

class LoadFavoriteList extends FavoriteEvent {}

class LoadFavoriteSchedule extends FavoriteEvent {}

class SaveSchedule extends FavoriteEvent {
  final String name;
  final String link1;
  final String? link2;
  final List<List<String>> scheduleList;
  final List<String>? daysOfWeekList;

  SaveSchedule({
    required this.name,
    required this.link1,
    this.link2,
    required this.scheduleList,
    this.daysOfWeekList,
  });
}

class DeleteSchedule extends FavoriteEvent {
  final String name;

  DeleteSchedule({required this.name});
}

class CheckSchedule extends FavoriteEvent {
  final String name;

  CheckSchedule({required this.name});
}
