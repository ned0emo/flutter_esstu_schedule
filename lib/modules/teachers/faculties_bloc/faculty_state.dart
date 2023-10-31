part of 'faculty_bloc.dart';

abstract class FacultyState {
  Map<String, Map<String, List<String>>>? facultyDepartmentLinkMap;
}

class FacultyInitial extends FacultyState {}

class FacultiesLoadingState extends FacultyState {}

class FacultiesLoadedState extends FacultyState {
  //final Map<String, Map<String, List<String>>> facultyDepartmentLinkMap;

  FacultiesLoadedState(
      {required Map<String, Map<String, List<String>>>
          facultyDepartmentLinkMap}) {
    this.facultyDepartmentLinkMap = facultyDepartmentLinkMap;
  }
}

class FacultiesErrorState extends FacultyState {
  final String message;

  FacultiesErrorState(this.message);
}

class CurrentFacultyState extends FacultyState {
  final String facultyName;
  final Map<String, List<String>> departmentsMap;

  final int weekNumber;

  CurrentFacultyState({
    required this.facultyName,
    required this.departmentsMap,
    required this.weekNumber,
    required Map<String, Map<String, List<String>>> facultyDepartmentLinkMap,
  }) {
    this.facultyDepartmentLinkMap = facultyDepartmentLinkMap;
  }

  String get firstDepartment => departmentsMap.keys.elementAt(0);

  String get firstLink1 => departmentsMap.values.elementAt(0)[0];

  String? get firstLink2 => departmentsMap.values.elementAt(0).length > 1
      ? departmentsMap.values.elementAt(0)[1]
      : null;
}
