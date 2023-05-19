part of 'faculty_bloc.dart';

@immutable
abstract class FacultyState {}

class FacultyInitial extends FacultyState {}

class FacultiesLoadingState extends FacultyState {}

class FacultiesLoadedState extends FacultyState {
  final Map<String, Map<String, List<String>>> facultyDepartmentLinkMap;

  FacultiesLoadedState({required this.facultyDepartmentLinkMap});
}

class FacultiesErrorState extends FacultyState {
  final String message;

  FacultiesErrorState(this.message);
}
