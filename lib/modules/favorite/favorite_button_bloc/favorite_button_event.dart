part of 'favorite_button_bloc.dart';

@immutable
abstract class FavoriteButtonEvent {}

class SaveSchedule extends FavoriteButtonEvent {
  final String name;
  final String scheduleType;
  final List<List<String>> scheduleList;
  final String? link1;
  final String? link2;
  final List<String>? daysOfWeekList;

  SaveSchedule({
    required this.name,
    required this.scheduleType,
    required this.scheduleList,
    this.link1,
    this.link2,
    this.daysOfWeekList,
  });
}

class DeleteSchedule extends FavoriteButtonEvent {
  final String name;

  DeleteSchedule({required this.name});
}

class CheckSchedule extends FavoriteButtonEvent {
  final String name;

  CheckSchedule({required this.name});
}
