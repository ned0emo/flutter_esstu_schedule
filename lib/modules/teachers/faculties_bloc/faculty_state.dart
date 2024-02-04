part of 'faculty_bloc.dart';

abstract class FacultyState {
  Map<String, Map<String, List<String>>>? facultyDepartmentLinkMap;
}

class FacultyInitial extends FacultyState {}

class FacultiesLoading extends FacultyState {}

class FacultiesLoaded extends FacultyState {
  FacultiesLoaded({
    required Map<String, Map<String, List<String>>> facultyDepartmentLinkMap,
  }) {
    this.facultyDepartmentLinkMap = facultyDepartmentLinkMap;
  }
}

class FacultiesError extends FacultyState {
  final String message;

  FacultiesError(this.message);
}

class CurrentFacultyLoaded extends FacultyState {
  final String facultyName;
  final Map<String, List<String>> departmentsMap;

  CurrentFacultyLoaded({
    required this.facultyName,
    required this.departmentsMap,
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
