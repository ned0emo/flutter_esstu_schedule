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
  final String currentTeacherName;
  final String currentDepartmentName;
  final int currentTeacherIndex;

  final List<ScheduleModel> teachersScheduleData;

  const DepartmentLoaded({
    String? appBarTitle,
    required this.currentTeacherName,
    required this.currentDepartmentName,
    required this.currentTeacherIndex,
    required this.teachersScheduleData,
  }) : super(appBarTitle: appBarTitle);

  DepartmentLoaded copyWith({
    String? appBarTitle,
    List<ScheduleModel>? teachersScheduleData,
    String? currentTeacherName,
    String? currentDepartmentName,
    int? currentTeacherIndex,
  }) {
    return DepartmentLoaded(
      appBarTitle: appBarTitle ?? this.appBarTitle,
      teachersScheduleData: teachersScheduleData ?? this.teachersScheduleData,
      currentTeacherName: currentTeacherName ?? this.currentTeacherName,
      currentDepartmentName: currentDepartmentName ?? this.currentDepartmentName,
      currentTeacherIndex: currentTeacherIndex ?? this.currentTeacherIndex,
    );
  }
}

class DepartmentError extends DepartmentState {
  final String? errorMessage;
  final String? warningMessage;

  const DepartmentError({this.errorMessage, this.warningMessage});
}
