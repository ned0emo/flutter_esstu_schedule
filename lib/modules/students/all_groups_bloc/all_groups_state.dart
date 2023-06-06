part of 'all_groups_bloc.dart';

abstract class AllGroupsState {}

class AllGroupsLoading extends AllGroupsState {}

class AllGroupsLoaded extends AllGroupsState {
  final Map<String, Map<String, String>> bakScheduleMap;
  final Map<String, Map<String, String>> magScheduleMap;
  final Map<String, Map<String, String>> colScheduleMap;
  final Map<String, Map<String, String>> zoScheduleMap;

  final String currentCourse;
  final String studType;
  final String currentGroup;

  final String? warningMessage;

  AllGroupsLoaded({
    required this.bakScheduleMap,
    required this.magScheduleMap,
    required this.colScheduleMap,
    required this.zoScheduleMap,
    required this.currentCourse,
    required this.studType,
    required this.currentGroup,
    this.warningMessage,
  });

  AllGroupsLoaded copyWith({
    Map<String, Map<String, String>>? bakScheduleMap,
    Map<String, Map<String, String>>? magScheduleMap,
    Map<String, Map<String, String>>? colScheduleMap,
    Map<String, Map<String, String>>? zoScheduleMap,
    String? currentCourse,
    String? currentGroup,
    String? studType,
    String? warningMessage,
  }) {
    return AllGroupsLoaded(
      bakScheduleMap: bakScheduleMap ?? this.bakScheduleMap,
      magScheduleMap: magScheduleMap ?? this.magScheduleMap,
      colScheduleMap: colScheduleMap ?? this.colScheduleMap,
      zoScheduleMap: zoScheduleMap ?? this.zoScheduleMap,
      currentCourse: currentCourse ?? this.currentCourse,
      currentGroup: currentGroup ?? this.currentGroup,
      studType: studType ?? this.studType,
      warningMessage: warningMessage,
    );
  }

  Map<String, String> get currentCourseMap => studType == StudentsType.bak
      ? bakScheduleMap[currentCourse]!
      : studType == StudentsType.mag
          ? magScheduleMap[currentCourse]!
          : studType == StudentsType.col
              ? colScheduleMap[currentCourse]!
              : zoScheduleMap[currentCourse]!;

  Map<String, String> courseMap(String course, String studType) {
    return studType == StudentsType.bak
        ? bakScheduleMap[course]!
        : studType == StudentsType.mag
            ? magScheduleMap[course]!
            : studType == StudentsType.col
                ? colScheduleMap[course]!
                : zoScheduleMap[course]!;
  }
}

class CourseSelected extends AllGroupsState {
  final Map<String, String> linkGroupMap;
  final String courseName;
  final String currentGroup;

  CourseSelected({
    required this.linkGroupMap,
    required this.courseName,
    required this.currentGroup,
  });
}

class AllGroupsError extends AllGroupsState {
  final String errorMessage;

  AllGroupsError(this.errorMessage);
}
