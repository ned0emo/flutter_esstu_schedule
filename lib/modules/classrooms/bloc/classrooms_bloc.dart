import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/teachers_parser.dart';

part 'classrooms_event.dart';
part 'classrooms_state.dart';

class ClassroomsBloc extends Bloc<ClassroomsEvent, ClassroomsState> {
  final TeachersParser _parser;

  final _streamController = StreamController<Map<String, String>>();

  ClassroomsBloc(MainRepository repository, TeachersParser parser)
      : _parser = parser,
        super(ClassroomsInitial()) {
    on<ClassroomsEvent>((event, emit) {});
    on<LoadClassroomsSchedule>(_loadClassroomsSchedule);
    on<ChangeBuilding>(_changeBuilding);
    on<ChangeClassroom>(_changeClassroom);
  }

  Future<void> _changeBuilding(
      ChangeBuilding event, Emitter<ClassroomsState> emit) async {
    final currentState = state;
    if (currentState is ClassroomsLoaded) {
      emit(currentState.copyWith(
        currentBuildingName: event.buildingName,
        currentClassroomIndex: 0,
        currentClassroomName:
            currentState.scheduleMap[event.buildingName]![0].name,
      ));
    }
  }

  Future<void> _changeClassroom(
      ChangeClassroom event, Emitter<ClassroomsState> emit) async {
    final currentState = state;
    if (currentState is ClassroomsLoaded) {
      final index = currentState.scheduleMap[currentState.currentBuildingName]!
          .indexWhere((element) => element.name == event.classroom);
      emit(currentState.copyWith(
        currentClassroomIndex: index,
        currentClassroomName: event.classroom,
      ));
    }
  }

  Future<void> _loadClassroomsSchedule(
      LoadClassroomsSchedule event, Emitter<ClassroomsState> emit) async {
    emit(const ClassroomsLoading());

    _streamController.stream.listen((event) {
      emit(ClassroomsLoading(
        percents: event['percents'] ?? '0',
        message: event['message'] ?? '',
      ));
    });

    /// Карта "корпус" - сортированная карта аудиторий:
    /// "аудитория" - список дней недели.
    /// В элементе списка дней недели пары
    final buildingsScheduleMap =
        await _parser.buildingsClassroomsMap(_streamController);
    await _streamController.close();

    if (buildingsScheduleMap == null) {
      emit(ClassroomsError(_parser.lastError ?? 'Ошибка'));
      return;
    }

    emit(ClassroomsLoaded(
      appBarTitle: buildingsScheduleMap.keys.first,
      currentBuildingName: buildingsScheduleMap.keys.first,
      scheduleMap: buildingsScheduleMap,
      currentClassroomIndex: 0,
      currentClassroomName:
      buildingsScheduleMap[buildingsScheduleMap.keys.first]![0].name,
    ));
  }

  @override
  Future<void> close() async {
    await _streamController.close();
    return super.close();
  }
}
