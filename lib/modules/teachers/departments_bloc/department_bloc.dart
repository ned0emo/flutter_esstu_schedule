import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_type.dart';
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
    on<ChangeTeacher>(_changeTeacher);
  }

  Future<void> _changeTeacher(
      ChangeTeacher event, Emitter<DepartmentState> emit) async {
    final currentState = state;
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

    List<String> departmentsPages = [];
    try {
      departmentsPages = await _teachersRepository
          .loadDepartmentPages(event.link1, link2: event.link2);
    } catch (e, stack) {
      emit(DepartmentError(
          errorMessage: Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
      return;
    }

    final List<ScheduleModel> teachersSchedule = [];

    try {
      for (String page in departmentsPages) {
        final splittedPage =
            page.replaceAll(' COLOR="#0000ff"', '').split('ff00ff">').skip(1);

        for (String teacherSection in splittedPage) {
          final teacherName = teacherSection
              .substring(0, teacherSection.indexOf('</P>'))
              .trim();

          bool isScheduleExist = true;
          var currentScheduleModel = teachersSchedule
              .firstWhereOrNull((element) => element.name == teacherName);

          if (currentScheduleModel == null) {
            currentScheduleModel = ScheduleModel(
              name: teacherName,
              type: ScheduleType.teacher,
              weeks: [],
              link1: event.link1,
              link2: event.link2,
            );
            isScheduleExist = false;
          }

          final daysOfWeekFromPage =
              teacherSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

          int dayOfWeekIndex = 0;
          for (String dayOfWeek in daysOfWeekFromPage) {
            final lessons =
                dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

            int lessonIndex = 0;
            for (String lessonSection in lessons) {
              final lesson = lessonSection
                  .substring(0, lessonSection.indexOf('</FONT>'))
                  .trim();

              final lessonChecker =
                  lesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

              if (lessonChecker.isEmpty) {
                if (++lessonIndex > 5) break;
                continue;
              }

              currentScheduleModel.updateWeek(
                  dayOfWeekIndex ~/ 6,
                  dayOfWeekIndex % 6,
                  lessonIndex,
                  LessonBuilder.createTeacherLesson(
                    lessonNumber: lessonIndex + 1,
                    lesson: lesson,
                  ));
              if (++lessonIndex > 5) break;
            }

            if (++dayOfWeekIndex > 11) break;
          }

          if (!isScheduleExist && currentScheduleModel.isNotEmpty) {
            teachersSchedule.add(currentScheduleModel);
          }
        }
      }

      if (teachersSchedule.isEmpty) {
        emit(DepartmentError(
            warningMessage: Logger.warning(
          title: 'Хмм.. Кажется, расписание для данной кафедры отсутствует',
          exception: 'teachersScheduleMap.isEmpty == true',
        )));

        return;
      }

      emit(DepartmentLoaded(
        appBarTitle: state.appBarTitle,
        teachersScheduleData: teachersSchedule,
        currentTeacherName: teachersSchedule[0].name,
        currentTeacherIndex: 0,
      ));
    } catch (e, stack) {
      emit(DepartmentError(
          errorMessage: Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
      return;
    }
  }
}
