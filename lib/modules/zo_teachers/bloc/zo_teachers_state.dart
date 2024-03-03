part of 'zo_teachers_bloc.dart';

@immutable
abstract class ZoTeachersState {
  final String? appBarTitle;

  const ZoTeachersState({this.appBarTitle});
}

class ZoTeachersInitial extends ZoTeachersState {}

class ZoTeachersError extends ZoTeachersState {
  final String message;

  const ZoTeachersError(this.message);
}

class ZoTeachersLoading extends ZoTeachersState {
  final String percents;
  final String message;

  const ZoTeachersLoading({
    super.appBarTitle,
    this.percents = '0',
    this.message = '',
  });
}

class ZoTeachersLoaded extends ZoTeachersState {
  final String currentBuildingName;
  final Map<String, List<ScheduleModel>> scheduleMap;
  final int currentClassroomIndex;
  final String currentClassroomName;

  const ZoTeachersLoaded({
    super.appBarTitle,
    required this.currentBuildingName,
    required this.scheduleMap,
    required this.currentClassroomIndex,
    required this.currentClassroomName,
  });

  ZoTeachersLoaded copyWith({
    String? currentBuildingName,
    Map<String, List<ScheduleModel>>? scheduleMap,
    int? currentClassroomIndex,
    String? currentClassroomName,
  }) {
    return ZoTeachersLoaded(
      appBarTitle: currentBuildingName ?? appBarTitle,
      currentBuildingName: currentBuildingName ?? this.currentBuildingName,
      scheduleMap: scheduleMap ?? this.scheduleMap,
      currentClassroomIndex:
      currentClassroomIndex ?? this.currentClassroomIndex,
      currentClassroomName: currentClassroomName ?? this.currentClassroomName,
    );
  }

  ScheduleModel? get scheduleModel => scheduleMap[currentBuildingName]?[currentClassroomIndex];
}
