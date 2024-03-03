import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/logger/custom_exception.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/teachers_parser.dart';

part 'department_event.dart';
part 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  final TeachersParser _parser;

  DepartmentBloc(TeachersParser parser)
      : _parser = parser,
        super(DepartmentInitial()) {
    on<LoadDepartment>(_loadDepartment);
    on<ChangeTeacher>(_changeTeacher);
  }

  Future<void> _changeTeacher(
      ChangeTeacher event, Emitter<DepartmentState> emit) async {
    final currentState = state;
    //emit(DepartmentLoading(appBarTitle: currentState.appBarTitle));
    //await Future.delayed(Duration(milliseconds: 100));

    if (currentState is DepartmentLoaded) {
      final index = currentState.teachersScheduleData
          .indexWhere((element) => element.name == event.teacherName);
      emit(currentState.copyWith(
        currentTeacherName: event.teacherName,
        currentTeacherIndex: index,
      ));
    }
  }

  Future<void> _loadDepartment(
      LoadDepartment event, Emitter<DepartmentState> emit) async {
    emit(DepartmentLoading(appBarTitle: event.departmentName));

    try{
      final teachersSchedule = await _parser.teachersScheduleList(
        link1: event.link1,
        link2: event.link2,
      );

      emit(DepartmentLoaded(
        appBarTitle: state.appBarTitle,
        teachersScheduleData: teachersSchedule,
        currentTeacherName: teachersSchedule[0].name,
        currentDepartmentName: event.departmentName,
        currentTeacherIndex: 0,
      ));
    }
    on CustomException catch(e){
      emit(DepartmentError(errorMessage: e.message));
    }
    catch (e){
      emit(DepartmentError(errorMessage: 'Ошибка: ${e.runtimeType}'));
    }
  }
}
