part of 'department_bloc.dart';

@immutable
abstract class DepartmentState {
}

class DepartmentInitial extends DepartmentState {}

class DepartmentLoading extends DepartmentState {}

class DepartmentLoaded extends DepartmentState {
  final String departmentName;
  final Map<String, List<List<String>>> teachersScheduleMap;
  final String link1;
  final String? link2;
  final int openedDayIndex;
  final int currentLesson;
  final String currentTeacher;
  final int weekNumber;

  DepartmentLoaded({
    required this.departmentName,
    required this.teachersScheduleMap,
    required this.link1,
    this.link2,
    required this.openedDayIndex,
    required this.currentLesson,
    required this.currentTeacher,
    required this.weekNumber,
  });

  DepartmentLoaded copyWith({
    String? departmentName,
    Map<String, List<List<String>>>? teachersScheduleMap,
    String? link1,
    String? link2,
    int? openedDayIndex,
    int? currentLesson,
    String? currentTeacher,
    int? weekNumber,
  }) {
    return DepartmentLoaded(
      departmentName: departmentName ?? this.departmentName,
      teachersScheduleMap: teachersScheduleMap ?? this.teachersScheduleMap,
      link1: link1 ?? this.link1,
      link2: link2 ?? this.link2,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
      currentTeacher: currentTeacher ?? this.currentTeacher,
      weekNumber: weekNumber ?? this.weekNumber,
    );
  }
}

class DepartmentError extends DepartmentState {
  final String message;

  DepartmentError({required this.message});
}
