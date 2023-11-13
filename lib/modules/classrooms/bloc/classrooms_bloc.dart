import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/modules/classrooms/repositories/classrooms_repository.dart';

part 'classrooms_event.dart';

part 'classrooms_state.dart';

class ClassroomsBloc extends Bloc<ClassroomsEvent, ClassroomsState> {
  final String facultyLinkBak = 'bakalavriat/craspisanEdt.htm';
  final String facultyLinkMag = 'spezialitet/craspisanEdt.htm';
  final int threadCount = 6;

  final ClassroomsRepository _classroomsRepository;

  ClassroomsBloc(ClassroomsRepository repository)
      : _classroomsRepository = repository,
        super(ClassroomsInitial()) {
    on<ClassroomsEvent>((event, emit) {});
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

    /// Карта "корпус" - сортированная карта аудиторий:
    /// "аудитория" - список дней недели.
    /// В элементе списка дней недели пары
    final Map<String, List<ScheduleModel>> buildingsScheduleMap = {
      '1 корпус': [],
      '2 корпус': [],
      '3 корпус': [],
      '4 корпус': [],
      '5 корпус': [],
      '6 корпус': [],
      '7 корпус': [],
      '8 корпус': [],
      '9 корпус': [],
      '10 корпус': [],
      '11 корпус': [],
      '12 корпус': [],
      '13 корпус': [],
      '14 корпус': [],
      '15 корпус': [],
    };

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
            final teacherName = teacherSection
                .substring(0, teacherSection.indexOf('</P>'))
                .trim();

            final daysOfWeekFromPage =
                teacherSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

            int dayOfWeekIndex = 0;
            for (String dayOfWeek in daysOfWeekFromPage) {
              final lessons =
                  dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

              int lessonIndex = 0;
              for (String lessonSection in lessons) {
                if (!lessonSection.contains('а.')) {
                  lessonIndex++;
                  continue;
                }

                final fullLesson = lessonSection
                    .substring(0, lessonSection.indexOf('</FONT>'))
                    .trim();
                final lessonChecker =
                    fullLesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

                if (lessonChecker.isEmpty) {
                  lessonIndex++;
                  continue;
                }

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
                  if (++lessonIndex > 5) break;
                  continue;
                }

                final building = '${_getBuildingByClassroom(classroom)} корпус';

                bool isScheduleExist = true;
                var currentScheduleModel = buildingsScheduleMap[building]
                    ?.firstWhereOrNull((element) => element.name == classroom);

                if (currentScheduleModel == null) {
                  currentScheduleModel = ScheduleModel(
                    name: classroom,
                    type: ScheduleType.classroom,
                    weeks: [],
                  );
                  isScheduleExist = false;
                }

                currentScheduleModel.updateWeek(
                  dayOfWeekIndex ~/ 6,
                  dayOfWeekIndex % 6,
                  lessonIndex,
                  LessonBuilder.createClassroomLesson(
                      lessonNumber: lessonIndex + 1,
                      lesson: '$teacherName $fullLesson}'),
                );

                if (!isScheduleExist && currentScheduleModel.isNotEmpty) {
                  buildingsScheduleMap[building]?.add(currentScheduleModel);
                }

                if (++lessonIndex > 5) break;
              }

              if (++dayOfWeekIndex > 11) break;
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
            emit(ClassroomsLoading(
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
        emit(
            ClassroomsLoading(percents: (progress / linksCount * 100).toInt()));
      } while (completedThreads < threadCount);

      if (errorCount > 8) {
        emit(ClassroomsError(Logger.error(
          title: Errors.scheduleError,
          exception: 'errorCount > 8',
        )));
        return;
      }

      buildingsScheduleMap.removeWhere((key, value) => value.isEmpty);
      for (var building in buildingsScheduleMap.keys) {
        buildingsScheduleMap[building]!
            .sort((a, b) => a.name.compareTo(b.name));
      }

      emit(ClassroomsLoaded(
        appBarTitle: buildingsScheduleMap.keys.first,
        currentBuildingName: buildingsScheduleMap.keys.first,
        scheduleMap: buildingsScheduleMap,
        currentClassroomIndex: 0,
        currentClassroomName:
            buildingsScheduleMap[buildingsScheduleMap.keys.first]![0].name,
      ));
    } catch (e, stack) {
      emit(ClassroomsError(Logger.error(
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
