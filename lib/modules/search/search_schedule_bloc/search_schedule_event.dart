part of 'search_schedule_bloc.dart';

@immutable
abstract class SearchScheduleEvent {}

class LoadSearchingSchedule extends SearchScheduleEvent {
  final String scheduleName;
  final String link1;
  final String? link2;
  final String scheduleType;

  LoadSearchingSchedule({
    required this.scheduleName,
    required this.link1,
    this.link2,
    required this.scheduleType,
  });
}
