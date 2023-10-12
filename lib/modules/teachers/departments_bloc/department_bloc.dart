import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_time_data.dart';
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
    } catch (e, stack) {
      emit(DepartmentError(Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
      return;
    }

    final Map<String, List<List<Lesson>>> teachersScheduleMap = {};

    try {
      for (String page in departmentsPages) {
        final splittedPage =
            page.replaceAll(' COLOR="#0000ff"', '').split('ff00ff">').skip(1);

        for (String teacherSection in splittedPage) {
          final teacherName = teacherSection
              .substring(0, teacherSection.indexOf('</P>'))
              .trim();

          if (teachersScheduleMap[teacherName] == null) {
            teachersScheduleMap[teacherName] = List.generate(
                12,
                (index) => List.generate(
                    6, (index) => Lesson(lessonNumber: index + 1)));
          }

          final daysOfWeekFromPage =
              teacherSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

          int dayOfWeekIndex = 0;
          for (String dayOfWeek in daysOfWeekFromPage) {
            final lessons =
                dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

            int lessonIndex = 0;
            for (String lessonSection in lessons) {
              String lesson = lessonSection
                  .substring(0, lessonSection.indexOf('</FONT>'))
                  .trim();

              teachersScheduleMap[teacherName]![dayOfWeekIndex][lessonIndex] =
                  LessonBuilder.createLessonIfTitleLonger(
                teachersScheduleMap[teacherName]![dayOfWeekIndex][lessonIndex],
                lesson,
              );
              // .updateLesson(lesson);

              if (++lessonIndex > 5) break;
            }

            if (++dayOfWeekIndex > 11) break;
          }
        }
      }

      if (teachersScheduleMap.isEmpty) {
        emit(DepartmentError(Logger.warning(
          title: 'Хмм.. Кажется, расписание для данной кафедры отсутствует',
          exception: 'teachersScheduleMap isEmpty',
        )));

        return;
      }

      emit(DepartmentLoaded(
        departmentName: event.departmentName,
        teachersScheduleMap: teachersScheduleMap,
        link1: event.link1,
        link2: event.link2,
        currentLesson: ScheduleTimeData.getCurrentLessonIndex(),
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
        currentTeacher: teachersScheduleMap.keys.elementAt(0),
        weekNumber: ScheduleTimeData.getCurrentWeekIndex(),
      ));
    } catch (e, stack) {
      emit(DepartmentError(Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
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
