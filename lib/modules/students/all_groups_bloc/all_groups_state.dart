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
  final Map<String, Map<String, Map<String, String>>> scheduleLinksMap;

  final String currentCourse;
  final String studType;
  final String currentGroup;

  final String? warningMessage;

  const AllGroupsLoaded({
    required this.scheduleLinksMap,
    required this.currentCourse,
    required this.studType,
    required this.currentGroup,
    this.warningMessage,
    String? appBarTitle,
  }) : super(appBarTitle: appBarTitle);

  AllGroupsLoaded copyWith({
    Map<String, Map<String, Map<String, String>>>? scheduleLinksMap,
    String? currentCourse,
    String? currentGroup,
    String? studType,
    String? warningMessage,
    String? appBarTitle,
  }) {
    return AllGroupsLoaded(
      scheduleLinksMap: scheduleLinksMap ?? this.scheduleLinksMap,
      currentCourse: currentCourse ?? this.currentCourse,
      currentGroup: currentGroup ?? this.currentGroup,
      studType: studType ?? this.studType,
      warningMessage: warningMessage,
      appBarTitle: appBarTitle ?? this.appBarTitle,
    );
  }

  Map<String, String> get currentCourseMap =>
      scheduleLinksMap[studType]![currentCourse]!;

  Map<String, String> courseMap(String course, String studType) =>
      scheduleLinksMap[studType]![course]!;
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
