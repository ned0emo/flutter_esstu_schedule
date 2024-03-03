part of 'zo_classroom_bloc.dart';

@immutable
abstract class ZoClassroomsState {
  final String? appBarTitle;

  const ZoClassroomsState({this.appBarTitle});
}

class ZoClassroomInitial extends ZoClassroomsState {}

class ZoClassroomsError extends ZoClassroomsState {
  final String message;

  const ZoClassroomsError(this.message);
}

class ZoClassroomsLoading extends ZoClassroomsState {
  final String percents;
  final String message;

  const ZoClassroomsLoading({
    super.appBarTitle,
    this.percents = '0',
    this.message = '',
  });
}

class ZoClassroomsLoaded extends ZoClassroomsState {
  final String currentBuildingName;
  final Map<String, List<ScheduleModel>> scheduleMap;
  final int currentClassroomIndex;
  final String currentClassroomName;

  const ZoClassroomsLoaded({
    super.appBarTitle,
    required this.currentBuildingName,
    required this.scheduleMap,
    required this.currentClassroomIndex,
    required this.currentClassroomName,
  });

  ZoClassroomsLoaded copyWith({
    String? currentBuildingName,
    Map<String, List<ScheduleModel>>? scheduleMap,
    int? currentClassroomIndex,
    String? currentClassroomName,
  }) {
    return ZoClassroomsLoaded(
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
