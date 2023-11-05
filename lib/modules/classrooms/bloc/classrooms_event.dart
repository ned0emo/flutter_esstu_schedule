part of 'classrooms_bloc.dart';

@immutable
abstract class ClassroomsEvent {}

class LoadClassroomsSchedule extends ClassroomsEvent {}

class ChangeBuilding extends ClassroomsEvent {
  final String buildingName;
  final String? classroom;

  ChangeBuilding(this.buildingName, {this.classroom});
}
