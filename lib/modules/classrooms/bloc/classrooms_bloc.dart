import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/modules/classrooms/repositories/classrooms_repository.dart';

part 'classrooms_event.dart';

part 'classrooms_state.dart';

class ClassroomsBloc extends Bloc<ClassroomsEvent, ClassroomsState> {
  final String facultyLinkBak = 'bakalavriat/craspisanEdt.htm';
  final String facultyLinkMag = 'spezialitet/craspisanEdt.htm';

  final ClassroomsRepository _classroomsRepository;

  ClassroomsBloc(ClassroomsRepository repository)
      : _classroomsRepository = repository,
        super(ClassroomsInitial()) {
    on<ClassroomsEvent>((event, emit) {});
    on<LoadClassroomsSchedule>(_loadClassroomsSchedule);
    on<ChangeBuilding>(_changeBuilding);
    on<ChangeOpenedDay>(_changeOpenedDay);
    on<ChangeClassroom>(_changeClassroom);
  }

  Future<void> _changeBuilding(
      ChangeBuilding event, Emitter<ClassroomsState> emit) async {
    final currentState = state;
    if (currentState is ClassroomsLoadedState) {
      emit(currentState.copyWith(
          currentBuildingName: event.buildingName,
          currentClassroom: event.classroom));
    }
  }

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<ClassroomsState> emit) async {
    final currentState = state;
    if (currentState is ClassroomsLoadedState) {
      emit(currentState.copyWith(openedDayIndex: event.dayIndex));
    }
  }

  Future<void> _changeClassroom(
      ChangeClassroom event, Emitter<ClassroomsState> emit) async {
    final currentState = state;
    if (currentState is ClassroomsLoadedState) {
      emit(currentState.copyWith(
        currentClassroom: event.classroom,
        openedDayIndex: Jiffy().dateTime.weekday - 1,
      ));
    }
  }

  Future<void> _loadClassroomsSchedule(
      LoadClassroomsSchedule event, Emitter<ClassroomsState> emit) async {
    emit(ClassroomsLoadingState());

    final facultyPages = await _classroomsRepository
        .loadFacultiesPages(facultyLinkBak, link2: facultyLinkMag);
    final Map<String, SplayTreeMap<String, List<List<String>>>>
        buildingsScheduleMap = {
      '1 корпус': SplayTreeMap<String, List<List<String>>>(),
      '2 корпус': SplayTreeMap<String, List<List<String>>>(),
      '3 корпус': SplayTreeMap<String, List<List<String>>>(),
      '4 корпус': SplayTreeMap<String, List<List<String>>>(),
      '5 корпус': SplayTreeMap<String, List<List<String>>>(),
      '6 корпус': SplayTreeMap<String, List<List<String>>>(),
      '7 корпус': SplayTreeMap<String, List<List<String>>>(),
      '8 корпус': SplayTreeMap<String, List<List<String>>>(),
      '9 корпус': SplayTreeMap<String, List<List<String>>>(),
      '10 корпус': SplayTreeMap<String, List<List<String>>>(),
      '11 корпус': SplayTreeMap<String, List<List<String>>>(),
      '12 корпус': SplayTreeMap<String, List<List<String>>>(),
      '13 корпус': SplayTreeMap<String, List<List<String>>>(),
      '14 корпус': SplayTreeMap<String, List<List<String>>>(),
      '15 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'16 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'17 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'18 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'19 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'20 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'21 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'22 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'23 корпус': SplayTreeMap<String, List<List<String>>>(),
      //'24 корпус': SplayTreeMap<String, List<List<String>>>(),
    };

    ///Создания списка ссылок на кафедры
    final List<String> departmentLinks = [];
    final List<String> linksList = ['bakalavriat/', 'spezialitet/'];
    int i = 0;
    for (String facultyPage in facultyPages) {
      Iterable<String> splittedFacultyPage = [];
      if (facultyPage.contains('faculty')) {
        splittedFacultyPage = facultyPage
            .replaceAll(RegExp(r"<!--.*-->"), '')
            .split('href="')
            .skip(1);
      }

      for (String linkSection in splittedFacultyPage) {
        departmentLinks.add(
            '${linksList[i]}${linkSection.substring(0, linkSection.indexOf('"'))}');
      }
      i++;
    }

    ///Загрузка и обработка всех страниц с кафедрами
    int progress = 0;
    int errorCount = 0;
    for (String link in departmentLinks) {
      try {
        final splittedDepartmentPage =
            (await _classroomsRepository.loadDepartmentPage(link))
                .replaceAll(' COLOR="#0000ff"', '')
                .split('ff00ff">')
                .skip(1);

        for (String teacherSection in splittedDepartmentPage) {
          String teacherName = '';
          try {
            teacherName = teacherSection.substring(
                teacherSection.indexOf(RegExp(r"[а-я]|[А-Я]")),
                teacherSection.indexOf('</P>'));
          } catch (e) {
            teacherName = e.runtimeType.toString();
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
              if (!lessonSection.contains('а.')) {
                i++;
                continue;
              }
              final fullLesson = lessonSection
                  .substring(0, lessonSection.indexOf('</FONT>'))
                  .trim();
              final lesson = fullLesson
                  .substring(fullLesson.indexOf('а.') + 2)
                  .trim()
                  .replaceAll('и/д', '')
                  .replaceAll('пр.', '')
                  .replaceAll('пр', '')
                  .replaceAll('д/кл', '')
                  .replaceAll('д/к', '');

              final classroom = lesson.contains(' ')
                  ? lesson.substring(0, lesson.indexOf(' '))
                  : lesson;

              if (!classroom.contains(RegExp(r"[0-9]"))) {
                i++;
                continue;
              }

              final building = '${_getBuildingByClassroom(classroom)} корпус';
              if (buildingsScheduleMap[building]![classroom] == null) {
                buildingsScheduleMap[building]![classroom] = [
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

              if (buildingsScheduleMap[building]![classroom]![j][i].length <
                  '$teacherName ${fullLesson.replaceFirst(classroom, '')}'
                      .length) {
                buildingsScheduleMap[building]![classroom]![j][i] =
                    '$teacherName ${fullLesson.replaceFirst(classroom, '')}';
              }

              /*if (classroomsMap[classroom] == null) {
                classroomsMap[classroom] = 1;
              } else {
                classroomsMap[classroom] = classroomsMap[classroom]! + 1;
              }*/

              i++;
              if (i > 5) {
                break;
              }
            }

            j++;
          }
        }

        progress++;
      } on RangeError catch (e) {
        print(e.message);
        print(e.stackTrace);
      } catch (e) {
        print(e.runtimeType);
        errorCount++;
      }

      if (errorCount > 4) {
        emit(ClassroomsErrorState('Ошибка загрузки страниц расписания кафедр'));
        return;
      }

      emit(ClassroomsLoadingState(
          percents: (progress / departmentLinks.length * 100).toInt()));
    }

    buildingsScheduleMap.removeWhere((key, value) => value.isEmpty);

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

    emit(ClassroomsLoadedState(
      weekNumber: (Jiffy().week + 1) % 2,
      currentBuildingName: buildingsScheduleMap.keys.first,
      scheduleMap: buildingsScheduleMap,
      currentClassroom:
          buildingsScheduleMap[buildingsScheduleMap.keys.first]!.keys.first,
      openedDayIndex: Jiffy().dateTime.weekday - 1,
      currentLesson: currentLesson,
    ));
  }

  int _getBuildingByClassroom(String classroom) {
    if (classroom.startsWith('0')) {
      return 10;
    }
    if (classroom.startsWith('11')) {
      return 11;
    }
    if (classroom.startsWith('12')) {
      return 12;
    }
    if (classroom.startsWith('13')) {
      return 13;
    }
    if (classroom.startsWith('14')) {
      return 14;
    }
    if (classroom.startsWith('15')) {
      return 15;
    }
    //if (classroom.startsWith('16')) {
    //  return 16;
    //}
    //if (classroom.startsWith('17')) {
    //  return 17;
    //}
    //if (classroom.startsWith('18')) {
    //  return 18;
    //}
    //if (classroom.startsWith('19')) {
    //  return 19;
    //}
    //if (classroom.startsWith('20')) {
    //  return 20;
    //}
    //if (classroom.startsWith('21')) {
    //  return 21;
    //}
    //if (classroom.startsWith('22')) {
    //  return 22;
    //}
    //if (classroom.startsWith('23')) {
    //  return 23;
    //}
    //if (classroom.startsWith('24')) {
    //  return 24;
    //}
    if (classroom.startsWith('2')) {
      return 2;
    }
    if (classroom.startsWith('3')) {
      return 3;
    }
    if (classroom.startsWith('4')) {
      return 4;
    }
    if (classroom.startsWith('5')) {
      return 5;
    }
    if (classroom.startsWith('6')) {
      return 6;
    }
    if (classroom.startsWith('7')) {
      return 7;
    }
    if (classroom.startsWith('8')) {
      return 8;
    }
    if (classroom.startsWith('9')) {
      return 9;
    }
    return 1;
  }
}
