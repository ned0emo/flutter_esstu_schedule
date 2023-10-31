part of 'department_bloc.dart';

@immutable
abstract class DepartmentState {
  final String? appBarTitle;

  const DepartmentState({this.appBarTitle});
}

class DepartmentInitial extends DepartmentState {}

class DepartmentLoading extends DepartmentState {
  const DepartmentLoading({String? appBarTitle})
      : super(appBarTitle: appBarTitle);
}

class DepartmentLoaded extends DepartmentState {
  final String initialTeacherName;

  final List<ScheduleModel> teachersScheduleData;

  const DepartmentLoaded({
    String? appBarTitle,
    required this.initialTeacherName,
    required this.teachersScheduleData,
  }) : super(appBarTitle: appBarTitle);

  DepartmentLoaded copyWith({
    String? appBarTitle,
    List<ScheduleModel>? teachersScheduleData,
    String? initialTeacherName,
  }) {
    return DepartmentLoaded(
      appBarTitle: appBarTitle ?? this.appBarTitle,
      teachersScheduleData: teachersScheduleData ?? this.teachersScheduleData,
      initialTeacherName: initialTeacherName ?? this.initialTeacherName,
    );
  }
}

class DepartmentError extends DepartmentState {
  final String? errorMessage;
  final String? warningMessage;

  const DepartmentError({this.errorMessage, this.warningMessage});
}
