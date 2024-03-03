import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/logger/custom_exception.dart';
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

    try {
      /// Карта "корпус" - сортированная карта аудиторий:
      /// "аудитория" - список дней недели.
      /// В элементе списка дней недели пары
      final buildingsScheduleMap =
          await _parser.buildingsClassroomsMap(_streamController);
      await _streamController.close();

      emit(ClassroomsLoaded(
        appBarTitle: buildingsScheduleMap.keys.first,
        currentBuildingName: buildingsScheduleMap.keys.first,
        scheduleMap: buildingsScheduleMap,
        currentClassroomIndex: 0,
        currentClassroomName:
            buildingsScheduleMap[buildingsScheduleMap.keys.first]![0].name,
      ));
    } on CustomException catch (e) {
      if(_streamController.hasListener) {
        await _streamController.close();
      }
      emit(ClassroomsError(e.message));
    } catch (e) {
      if(_streamController.hasListener) {
        await _streamController.close();
      }
      emit(ClassroomsError('Ошибка: ${e.runtimeType}'));
    }
  }

  @override
  Future<void> close() async {
    if(_streamController.hasListener) {
      await _streamController.close();
    }
    return super.close();
  }
}
