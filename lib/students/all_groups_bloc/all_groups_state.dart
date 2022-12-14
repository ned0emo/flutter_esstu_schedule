part of 'all_groups_cubit.dart';

abstract class AllGroupsState {}

class AllGroupsLoading extends AllGroupsState {}

class AllGroupsLoaded extends AllGroupsState {}

class CourseSelected extends AllGroupsState {
  final Map<String, String> linkGroupMap;
  final String typeLink1;
  final String typeLink2;
  final String courseName;
  final String currentGroup;

  CourseSelected({
    required this.linkGroupMap,
    required this.courseName,
    required this.typeLink1,
    required this.currentGroup,
    this.typeLink2 = '',
  });
}

class AllGroupsError extends AllGroupsState {}
