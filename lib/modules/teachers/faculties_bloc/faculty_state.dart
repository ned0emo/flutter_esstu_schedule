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

class CurrentFacultyState extends FacultyState {
  final String facultyName;
  final Map<String, List<String>> departmentsMap;
  final int weekNumber;

  CurrentFacultyState({
    required this.facultyName,
    required this.departmentsMap,
    required this.weekNumber,
  });

  String get abbreviatedFacultyName {
    if (facultyName.length < 26) {
      return facultyName;
    }

    String newStr = facultyName[0];

    for (int i = 0; i < facultyName.length - 1; i++) {
      if (facultyName[i] == ' ' || facultyName[i] == '-') {
        newStr += facultyName[i + 2] == ' '
            ? facultyName[i + 1]
            : facultyName[i + 1].toUpperCase();
      }
    }

    return newStr;
  }
}
