part of 'all_groups_bloc.dart';

@immutable
abstract class AllGroupsState {
  final String? appBarTitle;

  const AllGroupsState({this.appBarTitle});
}

class AllGroupsLoading extends AllGroupsState {
  const AllGroupsLoading({String? appBarTitle})
      : super(appBarTitle: appBarTitle);
}

class AllGroupsLoaded extends AllGroupsState {
  final Map<String, Map<String, String>> bakScheduleMap;
  final Map<String, Map<String, String>> magScheduleMap;
  final Map<String, Map<String, String>> colScheduleMap;
  final Map<String, Map<String, String>> zoScheduleMap;

  final String currentCourse;
  final String studType;
  final String currentGroup;

  final String? warningMessage;

  const AllGroupsLoaded({
    required this.bakScheduleMap,
    required this.magScheduleMap,
    required this.colScheduleMap,
    required this.zoScheduleMap,
    required this.currentCourse,
    required this.studType,
    required this.currentGroup,
    this.warningMessage,
    String? appBarTitle,
  }) : super(appBarTitle: appBarTitle);

  AllGroupsLoaded copyWith({
    Map<String, Map<String, String>>? bakScheduleMap,
    Map<String, Map<String, String>>? magScheduleMap,
    Map<String, Map<String, String>>? colScheduleMap,
    Map<String, Map<String, String>>? zoScheduleMap,
    String? currentCourse,
    String? currentGroup,
    String? studType,
    String? warningMessage,
    String? appBarTitle,
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
      appBarTitle: appBarTitle ?? this.appBarTitle,
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

  const CourseSelected({
    required this.linkGroupMap,
    required this.courseName,
    required this.currentGroup,
    String? appBarTitle,
  }) : super(appBarTitle: appBarTitle);
}

class AllGroupsError extends AllGroupsState {
  final String errorMessage;

  const AllGroupsError(this.errorMessage);
}
