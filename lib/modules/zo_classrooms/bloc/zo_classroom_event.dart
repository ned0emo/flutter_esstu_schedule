part of 'zo_classroom_bloc.dart';

@immutable
abstract class ZoClassroomEvent {}

class LoadZoClassroomsSchedule extends ZoClassroomEvent {}

class ChangeZoBuilding extends ZoClassroomEvent {
  final String buildingName;

  ChangeZoBuilding(this.buildingName);
}

class ChangeZoClassroom extends ZoClassroomEvent {
  final String classroom;

  ChangeZoClassroom({required this.classroom});
}
