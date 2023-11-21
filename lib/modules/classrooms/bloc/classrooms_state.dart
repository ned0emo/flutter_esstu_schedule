part of 'classrooms_bloc.dart';

@immutable
abstract class ClassroomsState {
  final String? appBarTitle;

  const ClassroomsState({this.appBarTitle});
}

class ClassroomsInitial extends ClassroomsState {}

class ClassroomsError extends ClassroomsState {
  final String message;

  const ClassroomsError(this.message);
}

class ClassroomsLoading extends ClassroomsState {
  final String percents;
  final String message;

  const ClassroomsLoading({
    String? appBarTitle,
    this.percents = '0',
    this.message = '',
  }) : super(appBarTitle: appBarTitle);
}

class ClassroomsLoaded extends ClassroomsState {
  final String currentBuildingName;
  final Map<String, List<ScheduleModel>> scheduleMap;
  final int currentClassroomIndex;
  final String currentClassroomName;

  const ClassroomsLoaded({
    String? appBarTitle,
    required this.currentBuildingName,
    required this.scheduleMap,
    required this.currentClassroomIndex,
    required this.currentClassroomName,
  }) : super(appBarTitle: appBarTitle);

  ClassroomsLoaded copyWith({
    String? currentBuildingName,
    Map<String, List<ScheduleModel>>? scheduleMap,
    int? currentClassroomIndex,
    String? currentClassroomName,
  }) {
    return ClassroomsLoaded(
      appBarTitle: currentBuildingName ?? appBarTitle,
      currentBuildingName: currentBuildingName ?? this.currentBuildingName,
      scheduleMap: scheduleMap ?? this.scheduleMap,
      currentClassroomIndex:
          currentClassroomIndex ?? this.currentClassroomIndex,
      currentClassroomName: currentClassroomName ?? this.currentClassroomName,
    );
  }
}
