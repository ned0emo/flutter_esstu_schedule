part of 'current_group_bloc.dart';

abstract class CurrentGroupState {}

class CurrentGroupInitial extends CurrentGroupState {}

class CurrentGroupLoading extends CurrentGroupState {}

class CurrentGroupLoaded extends CurrentGroupState {
  final String name;
  final List<List<Lesson>> scheduleList;
  final String link;
  final int openedDayIndex;
  final int currentLesson;
  final int weekNumber;

  final List<String>? daysOfWeekList;
  final String? message;

  CurrentGroupLoaded({
    required this.name,
    required this.scheduleList,
    required this.link,
    required this.openedDayIndex,
    required this.currentLesson,
    required this.weekNumber,
    this.daysOfWeekList,
    this.message,
  });

  ///
  /// [message] не копируется, так оно для одноразового вызова AlertDialog
  ///
  CurrentGroupLoaded copyWith({
    String? name,
    List<List<Lesson>>? scheduleList,
    String? link,
    int? openedDayIndex,
    int? currentLesson,
    int? weekNumber,
    List<String>? daysOfWeekList,
  }) {
    return CurrentGroupLoaded(
      name: name ?? this.name,
      scheduleList: scheduleList ?? this.scheduleList,
      link: link ?? this.link,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
      weekNumber: weekNumber ?? this.weekNumber,
      daysOfWeekList: daysOfWeekList ?? this.daysOfWeekList,
    );
  }

  int get numOfWeeks =>
      scheduleList.length == 12 ? 2 : scheduleList.length ~/ 7;

  bool get isZo => scheduleList.length == 12 ? false : true;
}

class CurrentGroupError extends CurrentGroupState {
  final String message;

  CurrentGroupError(this.message);
}
