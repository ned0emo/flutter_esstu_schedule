part of 'classrooms_bloc.dart';

@immutable
abstract class ClassroomsEvent {}

class LoadClassroomsSchedule extends ClassroomsEvent {}

class ChangeBuilding extends ClassroomsEvent {
  final String buildingName;

  ChangeBuilding(this.buildingName);
}

class ChangeClassroom extends ClassroomsEvent{
  final String classroom;

  ChangeClassroom({required this.classroom});
}
