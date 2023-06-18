import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/schedule_time_data.dart';
import 'package:schedule/modules/teachers/repositories/teachers_repository.dart';

part 'department_event.dart';

part 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  final TeachersRepository _teachersRepository;

  DepartmentBloc(TeachersRepository repository)
      : _teachersRepository = repository,
        super(DepartmentInitial()) {
    on<DepartmentEvent>((event, emit) {});
    on<LoadDepartment>(_loadDepartment);
    on<ChangeOpenedDay>(_changeOpenedDay);
    on<ChooseTeacher>(_chooseTeacher);
  }

  Future<void> _chooseTeacher(
      ChooseTeacher event, Emitter<DepartmentState> emit) async {
    final currentState = state;
    if (currentState is DepartmentLoaded) {
      emit(DepartmentLoading());
      await Future.delayed(const Duration(milliseconds: 300));

      emit(currentState.copyWith(
        currentTeacher: event.teacherName,
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
      ));
    }
  }

  Future<void> _loadDepartment(
      LoadDepartment event, Emitter<DepartmentState> emit) async {
    emit(DepartmentLoading());

    List<String> departmentsPages = [];
    try {
      departmentsPages = await _teachersRepository
          .loadDepartmentPages(event.link1, link2: event.link2);
    } on SocketException catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка загрузки страницы кафедры',
        'Отсутствие интернета или недоступность сайта: ${e.message}',
      );
      emit(DepartmentError(
          message: 'Ошибка загрузки страницы кафедры\n${e.message}'));
      return;
    } catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка загрузки страницы кафедры',
        'Неизвестная ошибка. Тип: ${e.runtimeType}',
      );
      emit(DepartmentError(
          message: 'Ошибка загрузки страницы кафедры\n${e.runtimeType}'));
      return;
    }

    final Map<String, List<List<String>>> teachersScheduleMap = {};

    try {
      for (String page in departmentsPages) {
        final splittedPage =
            page.replaceAll(' COLOR="#0000ff"', '').split('ff00ff">').skip(1);

        for (String teacherSection in splittedPage) {
          final teacherName = teacherSection
              .substring(0, teacherSection.indexOf('</P>'))
              .trim();

          if (teachersScheduleMap[teacherName] == null) {
            teachersScheduleMap[teacherName] = [
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
              ['', '', '', '', '', ''],
            ];
          }

          final daysOfWeekFromPage =
              teacherSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

          int j = 0;
          for (String dayOfWeek in daysOfWeekFromPage) {
            if (j == 12) break;

            final lessons =
                dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

            int i = 0;
            for (String lessonSection in lessons) {
              final lesson = lessonSection
                  .substring(0, lessonSection.indexOf('</FONT>'))
                  .trim();

              if (teachersScheduleMap[teacherName]![j][i].length <
                  lesson.length) {
                teachersScheduleMap[teacherName]![j][i] = lesson;
              }
              i++;
              if (i > 5) {
                break;
              }
            }

            j++;
          }
        }
      }

      emit(DepartmentLoaded(
        departmentName: event.departmentName,
        teachersScheduleMap: teachersScheduleMap,
        link1: event.link1,
        link2: event.link2,
        currentLesson: ScheduleTimeData.getCurrentLessonNumber(),
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
        currentTeacher: teachersScheduleMap.keys.elementAt(0),
        weekNumber: ScheduleTimeData.getCurrentWeekNumber(),
      ));
    } catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка обработки страницы кафедры',
        'Неизвестная ошибка. Тип: ${e.runtimeType}',
      );
      emit(DepartmentError(
          message: 'Ошибка обработки страницы кафедры\n${e.runtimeType}'));
      return;
    }
  }

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<DepartmentState> emit) async {
    final currentState = state;

    if (currentState is DepartmentLoaded) {
      emit(currentState.copyWith(openedDayIndex: event.dayIndex));
    }
  }
}
