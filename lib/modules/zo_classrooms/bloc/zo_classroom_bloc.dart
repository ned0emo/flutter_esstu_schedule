import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger/custom_exception.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/students_parser.dart';

part 'zo_classroom_event.dart';

part 'zo_classroom_state.dart';

class ZoClassroomsBloc extends Bloc<ZoClassroomEvent, ZoClassroomsState> {
  final StudentsParser _parser;

  final _streamController = StreamController<Map<String, String>>();

  ZoClassroomsBloc(StudentsParser parser)
      : _parser = parser,
        super(ZoClassroomInitial()) {
    on<LoadZoClassroomsSchedule>(_loadZoClassroomsSchedule);
    on<ChangeZoBuilding>(_changeZoBuilding);
    on<ChangeZoClassroom>(_changeZoClassroom);
  }

  Future<void> _changeZoBuilding(
      ChangeZoBuilding event, Emitter<ZoClassroomsState> emit) async {
    final currentState = state;
    if (currentState is ZoClassroomsLoaded) {
      emit(currentState.copyWith(
        currentBuildingName: event.buildingName,
        currentClassroomIndex: 0,
        currentClassroomName:
            currentState.scheduleMap[event.buildingName]![0].name,
      ));
    }
  }

  Future<void> _changeZoClassroom(
      ChangeZoClassroom event, Emitter<ZoClassroomsState> emit) async {
    final currentState = state;
    if (currentState is ZoClassroomsLoaded) {
      final index = currentState.scheduleMap[currentState.currentBuildingName]!
          .indexWhere((element) => element.name == event.classroom);
      emit(currentState.copyWith(
        currentClassroomIndex: index,
        currentClassroomName: event.classroom,
      ));
    }
  }

  Future<void> _loadZoClassroomsSchedule(
      LoadZoClassroomsSchedule event, Emitter<ZoClassroomsState> emit) async {
    emit(const ZoClassroomsLoading());

    _streamController.stream.listen((event) {
      emit(ZoClassroomsLoading(
        percents: event['percents'] ?? '0',
        message: event['message'] ?? '',
      ));
    });
    try {
      /// Карта "корпус" - сортированная карта аудиторий:
      /// "аудитория" - список дней недели.
      /// В элементе списка дней недели пары
      final buildingsScheduleMap =
          await _parser.buildingsZoClassroomsMap(_streamController);
      await _streamController.close();

      emit(ZoClassroomsLoaded(
        appBarTitle: buildingsScheduleMap.keys.first,
        currentBuildingName: buildingsScheduleMap.keys.first,
        scheduleMap: buildingsScheduleMap,
        currentClassroomIndex: 0,
        currentClassroomName:
            buildingsScheduleMap[buildingsScheduleMap.keys.first]![0].name,
      ));
    } on CustomException catch (e) {
      if (_streamController.hasListener) {
        await _streamController.close();
      }
      emit(ZoClassroomsError(e.message));
    } catch (e) {
      if (_streamController.hasListener) {
        await _streamController.close();
      }
      emit(ZoClassroomsError('Ошибка: ${e.runtimeType}'));
    }
  }

  @override
  Future<void> close() async {
    if (_streamController.hasListener) {
      await _streamController.close();
    }
    return super.close();
  }
}
