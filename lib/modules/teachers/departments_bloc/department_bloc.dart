import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';
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
      emit(currentState.copyWith(
        currentTeacher: event.teacherName,
        openedDayIndex: Jiffy().dateTime.weekday - 1,
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
    } catch (e) {
      emit(DepartmentError(message: e.runtimeType.toString()));
      return;
    }

    final Map<String, List<List<String>>> teachersScheduleMap = {};

    for (String page in departmentsPages) {
      final splittedPage =
          page.replaceAll(' COLOR="#0000ff"', '').split('ff00ff">').skip(1);

      for (String teacherSection in splittedPage) {
        String teacherName = '';
        try {
          teacherName = teacherSection.substring(
              teacherSection.indexOf(RegExp(r"[а-я]|[А-Я]")),
              teacherSection.indexOf('</P>'));
        } catch (e) {
          teacherName = e.runtimeType.toString();
        }

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
          if(j == 12) break;

          final lessons = dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

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

    int currentLesson = -1;
    final currentTime = Jiffy().dateTime.minute + Jiffy().dateTime.hour * 60;
    if (currentTime >= 540 && currentTime <= 635) {
      currentLesson = 0;
    } else if (currentTime >= 645 && currentTime <= 740) {
      currentLesson = 1;
    } else if (currentTime >= 780 && currentTime <= 875) {
      currentLesson = 2;
    } else if (currentTime >= 885 && currentTime <= 980) {
      currentLesson = 3;
    } else if (currentTime >= 985 && currentTime <= 1080) {
      currentLesson = 4;
    } else if (currentTime >= 1085 && currentTime <= 1180) {
      currentLesson = 5;
    }

    emit(DepartmentLoaded(
      departmentName: event.departmentName,
      teachersScheduleMap: teachersScheduleMap,
      currentLesson: currentLesson,
      openedDayIndex: Jiffy().dateTime.weekday - 1,
      currentTeacher: teachersScheduleMap.keys.elementAt(0),
    ));
  }

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<DepartmentState> emit) async {
    final currentState = state;

    if (currentState is DepartmentLoaded) {
      emit(currentState.copyWith(openedDayIndex: event.dayIndex));
    }
  }
}
