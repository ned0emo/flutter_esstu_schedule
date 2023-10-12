import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_time_data.dart';
import 'package:schedule/modules/classrooms/repositories/classrooms_repository.dart';

part 'classrooms_event.dart';

part 'classrooms_state.dart';

class ClassroomsBloc extends Bloc<ClassroomsEvent, ClassroomsState> {
  final String facultyLinkBak = 'bakalavriat/craspisanEdt.htm';
  final String facultyLinkMag = 'spezialitet/craspisanEdt.htm';
  final int threadCount = 6;

  /// Карта "корпус" - сортированная карта аудиторий:
  /// "аудитория" - список дней недели.
  /// В элементе списка дней недели пары
  final Map<String, SplayTreeMap<String, List<List<Lesson>>>>
      _buildingsScheduleMap = {
    '1 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '2 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '3 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '4 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '5 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '6 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '7 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '8 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '9 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '10 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '11 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '12 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '13 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '14 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
    '15 корпус': SplayTreeMap<String, List<List<Lesson>>>(),
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
      emit(ClassroomsLoadingState());
      await Future.delayed(const Duration(milliseconds: 300));

      emit(currentState.copyWith(
        currentClassroom: event.classroom,
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
      ));
    }
  }

  Future<void> _loadClassroomsSchedule(
      LoadClassroomsSchedule event, Emitter<ClassroomsState> emit) async {
    emit(ClassroomsLoadingState());

    int progress = 0;
    int errorCount = 0;
    int completedThreads = 0;
    int linksCount = 0;

    Future<void> loadDepartmentPages(List<String> depLinks) async {
      int localErrorCount = 0;

      ///Загрузка и обработка всех страниц с кафедрами
      for (String link in depLinks) {
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
            } catch (e, stack) {
              Logger.warning(
                title: Errors.pageParsingError,
                exception: e,
                stack: stack,
              );

              teacherName = 'Не распознано';
            }

            final daysOfWeekFromPage =
                teacherSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

            int j = 0;
            for (String dayOfWeek in daysOfWeekFromPage) {
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
                if (_buildingsScheduleMap[building]![classroom] == null) {
                  _buildingsScheduleMap[building]![classroom] = List.generate(
                      12,
                      (index) => List.generate(
                          6, (index) => Lesson(lessonNumber: index + 1)));
                }

                _buildingsScheduleMap[building]![classroom]![j][i] =
                    LessonBuilder.createLessonIfTitleLonger(
                  _buildingsScheduleMap[building]![classroom]![j][i],
                  '$teacherName ${fullLesson.replaceFirst(classroom, '')}',
                );

                if (++i > 5) break;
              }

              if (++j > 11) break;
            }
          }

          progress++;
        } catch (e, stack) {
          Logger.warning(
              title: Errors.pageLoadingError, exception: e, stack: stack);

          localErrorCount++;
        }

        if (localErrorCount > 4) {
          completedThreads++;
          errorCount += localErrorCount;
          return;
        }
      }

      completedThreads++;
    }

    try {
      final facultyPages = await _classroomsRepository
          .loadFacultiesPages(facultyLinkBak, link2: facultyLinkMag);

      ///Создания списка ссылок на кафедры
      ///
      /// Список содержит [threadCount] списков ссылок, которые потом параллельно
      /// (ну типо) загружаются и формируют мэп по корпусам
      final List<List<String>> departmentLinks =
          List.generate(threadCount, (index) => []);
      final List<String> linksList = ['bakalavriat/', 'spezialitet/'];
      int i = 0;
      for (String facultyPage in facultyPages) {
        List<String> splittedFacultyPage = [];
        if (facultyPage.contains('faculty')) {
          splittedFacultyPage = facultyPage
              .replaceAll(RegExp(r"<!--.*-->"), '')
              .split('href="')
              .skip(1)
              .toList();
        }

        int j = 0;
        for (String linkSection in splittedFacultyPage) {
          departmentLinks[j % threadCount].add(
            '${linksList[i]}${linkSection.substring(0, linkSection.indexOf('"'))}',
          );
          j++;
        }
        linksCount += j;
        i++;
      }

      /// Собственно [threadCount] асинхронных потоков по загрузке страниц. Далее
      /// ождиание окончания их работы с отображением прогресса.
      ///
      /// Если прогресс слишком долго не идет (капитализм как-никак), то выводится
      /// сообщение об этом. Проверяется зависание счетчиком сравнения предыдущего
      /// прогресса с нынешним
      int freezeCount = 0;
      int oldProgress = progress;
      for (int i = 0; i < threadCount; i++) {
        loadDepartmentPages(departmentLinks[i]);
      }
      do {
        await Future.delayed(const Duration(milliseconds: 300));

        if (oldProgress == progress) {
          freezeCount++;
          if (freezeCount > 20) {
            emit(ClassroomsLoadingState(
              percents: (progress / linksCount * 100).toInt(),
              message:
                  'Загрузка длится слишком долго. Возможно, что-то пошло не так...',
            ));
          }
          continue;
        } else {
          oldProgress = progress;
          freezeCount = 0;
        }
        emit(ClassroomsLoadingState(
            percents: (progress / linksCount * 100).toInt()));
      } while (completedThreads < threadCount);

      if (errorCount > 8) {
        emit(ClassroomsErrorState(Logger.error(
          title: Errors.scheduleError,
          exception: 'errorCount > 8',
        )));
        return;
      }

      _buildingsScheduleMap.removeWhere((key, value) => value.isEmpty);

      emit(ClassroomsLoadedState(
        weekNumber: ScheduleTimeData.getCurrentWeekIndex(),
        currentBuildingName: _buildingsScheduleMap.keys.first,
        scheduleMap: _buildingsScheduleMap,
        currentClassroom:
            _buildingsScheduleMap[_buildingsScheduleMap.keys.first]!.keys.first,
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
        currentLesson: ScheduleTimeData.getCurrentLessonIndex(),
      ));
    } catch (e, stack) {
      emit(ClassroomsErrorState(Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
    }
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
