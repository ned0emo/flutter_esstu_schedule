part of 'department_bloc.dart';

@immutable
abstract class DepartmentState {
  final daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];
}

class DepartmentInitial extends DepartmentState {}

class DepartmentLoading extends DepartmentState {}

class DepartmentLoaded extends DepartmentState {
  final String departmentName;
  final Map<String, List<List<String>>> teachersScheduleMap;
  final int openedDayIndex;
  final int currentLesson;
  final String? currentTeacher;

  DepartmentLoaded({
    required this.departmentName,
    required this.teachersScheduleMap,
    required this.openedDayIndex,
    required this.currentLesson,
    this.currentTeacher,
  });

  DepartmentLoaded copyWith({
    String? departmentName,
    Map<String, List<List<String>>>? teachersScheduleMap,
    int? openedDayIndex,
    int? currentLesson,
    int? weekNumber,
    String? currentTeacher,
  }) {
    return DepartmentLoaded(
      departmentName: departmentName ?? this.departmentName,
      teachersScheduleMap: teachersScheduleMap ?? this.teachersScheduleMap,
      openedDayIndex: openedDayIndex ?? this.openedDayIndex,
      currentLesson: currentLesson ?? this.currentLesson,
      currentTeacher: currentTeacher ?? this.currentTeacher,
    );
  }

  String get abbreviatedDepartmentName {
    if (departmentName.length < 26) {
      return departmentName;
    }

    String newStr = departmentName[0];

    for (int i = 0; i < departmentName.length - 1; i++) {
      if (departmentName[i] == ' ' || departmentName[i] == '-' || departmentName[i] == '.') {
        newStr += departmentName[i + 2] == ' '
            ? departmentName[i + 1]
            : departmentName[i + 1].toUpperCase();
      }
    }

    return newStr;
  }
}

class DepartmentError extends DepartmentState {}
