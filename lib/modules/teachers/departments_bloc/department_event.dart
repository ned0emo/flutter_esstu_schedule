part of 'department_bloc.dart';

@immutable
abstract class DepartmentEvent {}

class LoadDepartment extends DepartmentEvent {
  final String departmentName;
  final String link1;
  final String? link2;

  LoadDepartment({
    required this.departmentName,
    required this.link1,
    this.link2,
  });
}

class ChangeTeacher extends DepartmentEvent{
  final String teacherName;

  ChangeTeacher({required this.teacherName});
}
