part of 'faculty_bloc.dart';

@immutable
abstract class FacultyEvent {}

class LoadFaculties extends FacultyEvent {}

class ChooseFaculty extends FacultyEvent {
  final String facultyName;
  final Map<String, List<String>> departmentsMap;

  ChooseFaculty({
    required this.facultyName,
    required this.departmentsMap,
  });
}
