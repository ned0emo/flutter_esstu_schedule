part of 'favorite_update_bloc.dart';

@immutable
abstract class FavoriteUpdateEvent {}

class UpdateSchedule extends FavoriteUpdateEvent {
  final String scheduleName;
  final List<List<Lesson>> scheduleList;
  final String scheduleType;
  final bool isAutoUpdate;

  final String? link1;
  final String? link2;
  final List<String>? customDaysOfWeek;

  UpdateSchedule({
    required this.scheduleName,
    required this.scheduleList,
    required this.scheduleType,
    required this.isAutoUpdate,
    required this.link1,
    required this.link2,
    required this.customDaysOfWeek,
  });

  String get fileName => '$scheduleType|$scheduleName';
}
