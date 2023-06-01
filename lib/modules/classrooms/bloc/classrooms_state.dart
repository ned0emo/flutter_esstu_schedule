part of 'classrooms_bloc.dart';

@immutable
abstract class ClassroomsState {}

class ClassroomsInitial extends ClassroomsState {}

class ClassroomsErrorState extends ClassroomsState {
  final String message;

  ClassroomsErrorState(this.message);
}

class ClassroomsLoadingState extends ClassroomsState {
  final int percents;

  ClassroomsLoadingState({this.percents = 0});
}

class ClassroomsLoadedState extends ClassroomsState {
  final int weekNumber;
  final String currentBuildingName;
  final Map<String, Map<String, List<List<String>>>> scheduleMap;
  final String currentClassroom;
  final int openedDayIndex;
  final int currentLesson;

  ClassroomsLoadedState({
    required this.weekNumber,
    required this.currentBuildingName,
    required this.scheduleMap,
    required this.currentClassroom,
    required this.openedDayIndex,
    required this.currentLesson,
  });

  ClassroomsLoadedState copyWith({
    int? weekNumber,
    String? currentBuildingName,
    Map<String, Map<String, List<List<String>>>>? scheduleMap,
    String? currentClassroom,
    int? openedDayIndex,
    int? currentLesson,
  }) {
    return ClassroomsLoadedState(
      weekNumber: weekNumber ?? this.weekNumber,
      currentBuildingName: currentBuildingName ?? this.currentBuildingName,
      scheduleMap: scheduleMap ?? this.scheduleMap,
      currentClassroom: currentClassroom ?? this.currentClassroom,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
    );
  }
}
