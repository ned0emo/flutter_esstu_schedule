import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/parser/teachers_parser.dart';
import 'package:schedule/core/static/schedule_time_data.dart';

part 'faculty_event.dart';
part 'faculty_state.dart';

class FacultyBloc extends Bloc<FacultyEvent, FacultyState> {
  final TeachersParser _parser;

  FacultyBloc(TeachersParser parser)
      : _parser = parser,
        super(FacultyInitial()) {
    on<FacultyEvent>((event, emit) {});
    on<LoadFaculties>(_loadFaculties);
    on<ChooseFaculty>(_chooseFaculty);
  }

  Future<void> _loadFaculties(
      LoadFaculties event, Emitter<FacultyState> emit) async {
    emit(FacultiesLoadingState());
    final facultyDepartmentLinkMap = await _parser.facultyDepartmentLinksMap();

    if (facultyDepartmentLinkMap == null) {
      emit(FacultiesErrorState(_parser.lastError ?? 'Неизвестная ошибка'));
      return;
    }

    emit(FacultiesLoadedState(
        facultyDepartmentLinkMap: facultyDepartmentLinkMap));
  }

  Future<void> _chooseFaculty(
      ChooseFaculty event, Emitter<FacultyState> emit) async {
    emit(CurrentFacultyState(
      facultyName: event.facultyName,
      departmentsMap: event.departmentsMap,
      weekNumber: ScheduleTimeData.getCurrentWeekIndex(),
      facultyDepartmentLinkMap: state.facultyDepartmentLinkMap ?? {},
    ));
  }
}
