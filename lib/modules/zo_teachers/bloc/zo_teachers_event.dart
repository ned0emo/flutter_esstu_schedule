part of 'zo_teachers_bloc.dart';

@immutable
abstract class ZoTeachersEvent {}

class LoadZoTeachersSchedule extends ZoTeachersEvent {}

class ChangeZoLetter extends ZoTeachersEvent {
  final String buildingName;

  ChangeZoLetter(this.buildingName);
}

class ChangeZoTeacher extends ZoTeachersEvent {
  final String classroom;

  ChangeZoTeacher({required this.classroom});
}
