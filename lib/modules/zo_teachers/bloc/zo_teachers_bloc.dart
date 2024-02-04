import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger/custom_exception.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/students_parser.dart';

part 'zo_teachers_event.dart';

part 'zo_teachers_state.dart';

class ZoTeachersBloc extends Bloc<ZoTeachersEvent, ZoTeachersState> {
  final StudentsParser _parser;

  final _streamController = StreamController<Map<String, String>>();

  ZoTeachersBloc(StudentsParser parser)
      : _parser = parser,
        super(ZoTeachersInitial()) {
    on<LoadZoTeachersSchedule>(_loadZoTeachersSchedule);
    on<ChangeZoLetter>(_changeZoLetter);
    on<ChangeZoTeacher>(_changeZoTeacher);
  }

  Future<void> _changeZoLetter(
      ChangeZoLetter event, Emitter<ZoTeachersState> emit) async {
    final currentState = state;
    if (currentState is ZoTeachersLoaded) {
      emit(currentState.copyWith(
        currentBuildingName: event.buildingName,
        currentClassroomIndex: 0,
        currentClassroomName:
            currentState.scheduleMap[event.buildingName]![0].name,
      ));
    }
  }

  Future<void> _changeZoTeacher(
      ChangeZoTeacher event, Emitter<ZoTeachersState> emit) async {
    final currentState = state;
    if (currentState is ZoTeachersLoaded) {
      final index = currentState.scheduleMap[currentState.currentBuildingName]!
          .indexWhere((element) => element.name == event.classroom);
      emit(currentState.copyWith(
        currentClassroomIndex: index,
        currentClassroomName: event.classroom,
      ));
    }
  }

  Future<void> _loadZoTeachersSchedule(
      LoadZoTeachersSchedule event, Emitter<ZoTeachersState> emit) async {
    emit(const ZoTeachersLoading());

    _streamController.stream.listen((event) {
      emit(ZoTeachersLoading(
        percents: event['percents'] ?? '0',
        message: event['message'] ?? '',
      ));
    });

    try {
      /// Карта "корпус" - сортированная карта аудиторий:
      /// "аудитория" - список дней недели.
      /// В элементе списка дней недели пары
      final buildingsScheduleMap =
          await _parser.lettersZoTeachersMap(_streamController);
      await _streamController.close();

      emit(ZoTeachersLoaded(
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
      emit(ZoTeachersError(e.message));
    } catch (e) {
      if (_streamController.hasListener) {
        await _streamController.close();
      }
      emit(ZoTeachersError('Ошибка: ${e.runtimeType}'));
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
