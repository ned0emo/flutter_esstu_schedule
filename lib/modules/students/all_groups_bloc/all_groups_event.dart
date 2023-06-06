part of 'all_groups_bloc.dart';

@immutable
abstract class AllGroupsEvent {}

class LoadAllGroups extends AllGroupsEvent {}

class SelectCourse extends AllGroupsEvent {
  final String courseName;
  final String studType;
  //final Map<String, String> groupLinkMap;

  SelectCourse({
    required this.courseName,
    required this.studType,
    //required this.groupLinkMap,
  });
}

class SelectGroup extends AllGroupsEvent {
  final String groupName;

  SelectGroup({required this.groupName});
}
