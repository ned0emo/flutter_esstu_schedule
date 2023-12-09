import 'dart:async';

import 'package:collection/collection.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/parser.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/schedule_links.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/students_type.dart';

class StudentsParser extends Parser {
  StudentsParser(super.repository);

  ///Мэп группа - ссылка по курсам
  Future<Map<String, Map<String, Map<String, String>>>?>
      courseGroupLinkMap() async {
    lastError = null;
    final schedulePages = <String>[];

    final studentsLinks = [
      ScheduleLinks.allBakGroups,
      ScheduleLinks.allMagGroups,
      ScheduleLinks.allZo1Groups,
      ScheduleLinks.allZo2Groups,
    ];

    final scheduleMap = <String, Map<String, Map<String, String>>>{
      StudentsType.bak: {
        '1 курс': {},
        '2 курс': {},
        '3 курс': {},
        '4 курс': {},
        '5 курс': {},
        '6 курс': {},
      },
      StudentsType.col: {
        '1 курс': {},
        '2 курс': {},
        '3 курс': {},
        '4 курс': {},
      },
      StudentsType.mag: {
        '1 курс': {},
        '2 курс': {},
      },
      StudentsType.zo1: {
        '1 курс': {},
        '2 курс': {},
        '3 курс': {},
        '4 курс': {},
        '5 курс': {},
        '6 курс': {},
      },
    };

    try {
      for (String link in studentsLinks) {
        schedulePages.add(await repository.loadPage(link));
      }

      _parseStudentGroups(
        scheduleMap,
        schedulePages,
        (map, name, link, type, i) {
          switch (type) {
            case (StudentsType.mag):
              final currentCourse = i % 6 + 1;
              if (currentCourse < 5) {
                scheduleMap[StudentsType.col]!['$currentCourse курс']![name] =
                    link;
              } else {
                scheduleMap[StudentsType.mag]!['${currentCourse - 4} курс']![
                    name] = link;
              }
              break;
            case (StudentsType.bak):
              scheduleMap[type]!['${i % 6 + 1} курс']![name] = link;
              break;
            default:
              scheduleMap[StudentsType.zo1]!['${i % 6 + 1} курс']![name] = link;
          }
        },
      );

      for (var key in scheduleMap.keys) {
        scheduleMap[key]!.removeWhere((k, v) => scheduleMap[key]![k]!.isEmpty);
      }
      scheduleMap.removeWhere((key, value) => scheduleMap[key]!.isEmpty);

      if (scheduleMap.isEmpty) {
        lastError = Logger.error(
          title: Errors.scheduleError,
          exception: 'Не найдено ни одного расписания. scheduleMap.isEmpty',
        );
        return null;
      }

      return scheduleMap;
    } catch (e, stack) {
      lastError = Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      );
    }

    return null;
  }

  /// Просто мэп группа - список ссылок. Список нужен для преподов, у студентов
  /// всегда можно вызывать 0 элемент
  Future<Map<String, List<String>>?> groupLinkMap({
    List<String>? defaultStudentsLinks,
    List<String>? defaultScheduleLinks,
    List<String>? defaultStudentsTypes,
  }) async {
    lastError = null;
    final schedulePages = <String>[];

    final studentsLinks = defaultStudentsLinks ??
        [
          ScheduleLinks.allBakGroups,
          ScheduleLinks.allMagGroups,
          ScheduleLinks.allZo1Groups,
          ScheduleLinks.allZo2Groups,
        ];

    final Map<String, List<String>> scheduleLinksMap = {};

    try {
      for (String link in studentsLinks) {
        schedulePages.add(await repository.loadPage(link));
      }

      _parseStudentGroups(
        scheduleLinksMap,
        schedulePages,
        (map, name, link, type, i) {
          map[name] ??= [];
          map[name]!.add(link);
        },
        defaultScheduleLinks: defaultScheduleLinks,
        defaultStudentsTypes: defaultStudentsTypes,
      );

      if (scheduleLinksMap.isEmpty) {
        lastError = Logger.error(
          title: Errors.scheduleError,
          exception:
              'Не найдено ни одной ссылки на расписание. scheduleLinksMap.isEmpty',
        );
        return null;
      }

      return scheduleLinksMap;
    } catch (e, stack) {
      lastError = Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      );
    }

    return null;
  }

  /// Непосредственно парсинг страниц с учебными группами.
  /// [map] - для различного хранения пар группа - ссылка
  /// [schedulePages] - страницы с учебными группами
  /// [mapCreating] - функция для заполнения переданного мэпа
  void _parseStudentGroups<T extends Map>(
    T map,
    List<String> schedulePages,
    void Function(T map, String name, String link, String type, int j)
        mapCreating, {
    List<String>? defaultScheduleLinks,
    List<String>? defaultStudentsTypes,
  }) async {
    final studentsScheduleLinks = defaultScheduleLinks ??
        [
          ScheduleLinks.bakPrefix,
          ScheduleLinks.magPrefix,
          ScheduleLinks.zo1Prefix,
          ScheduleLinks.zo2Prefix,
        ];

    final studentsTypes = defaultStudentsTypes ??
        [
          StudentsType.bak,
          StudentsType.mag,
          StudentsType.col,
          StudentsType.zo1,
        ];

    int i = 0;
    for (String page in schedulePages) {
      final splittedPage = page.split('HREF="').skip(1);

      int emptinessCounter = 0;
      int j = 0;
      for (String groupSection in splittedPage) {
        if (emptinessCounter > 11) break;

        final name = groupSection.substring(
            groupSection.indexOf('n">') + 3, groupSection.indexOf('</FONT'));
        if (!name.contains(RegExp(r'[0-9]|[А-Я]'))) {
          emptinessCounter++;
          j++;
          continue;
        }
        emptinessCounter = 0;

        final link = '${studentsScheduleLinks[i]}/'
            '${groupSection.substring(0, groupSection.indexOf('">'))}';

        mapCreating(map, name, link, studentsTypes[i], j++);
      }
      i++;
    }
  }

  /// Создание мэпа корпус - список аудиторий.
  /// [streamController] - для отслеживания прогресса в блоке, после окончания
  /// обязательно закрывать
  Future<Map<String, List<ScheduleModel>>?> buildingsZoClassroomsMap(
    StreamController<Map<String, String>> streamController,
  ) async {
    lastError = null;
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

    int getBuildingByClassroom(String classroom) {
      if (classroom.length > 1) {
        final start = classroom.substring(0, 2);
        switch (start) {
          case '11':
            return 11;
          case '12':
            return 12;
          case '13':
            return 13;
          case '14':
            return 14;
          case '15':
            return 15;
        }
      }
      if (classroom.isNotEmpty) {
        final start = classroom[0];
        switch (start) {
          case '0':
            return 10;
          case '1':
            return 1;
          case '2':
            return 2;
          case '3':
            return 3;
          case '4':
            return 4;
          case '5':
            return 5;
          case '6':
            return 6;
          case '7':
            return 7;
          case '8':
            return 8;
          case '9':
            return 9;
        }
      }

      return 1;
    }

    final groupLinkMap1 = await groupLinkMap(
      defaultStudentsLinks: [
        ScheduleLinks.allZo1Groups,
        ScheduleLinks.allZo2Groups,
      ],
      defaultScheduleLinks: [
        ScheduleLinks.zo1Prefix,
        ScheduleLinks.zo2Prefix,
      ],
      defaultStudentsTypes: [
        StudentsType.zo1,
        StudentsType.zo1,
      ],
    );

    if (groupLinkMap1 == null) {
      lastError = Logger.error(
        title: Errors.zoClassroomsError,
        exception: 'Невозможно получить список заочных групп. '
            'groupLinkMap == null',
      );
      return null;
    }

    String warnings = '';

    /// Данные для парллельной загрузки
    int progress = 0;
    int globalErrorsCount = 0;
    int completeThreads = 0;

    const threadsCount = 6;
    final linksCount = groupLinkMap1.length;

    final threadsMaps =
        List.generate(threadsCount, (index) => <String, List<String>>{});

    int i = 0;
    for (var key in groupLinkMap1.keys) {
      threadsMaps[i++ % threadsCount][key] = groupLinkMap1[key]!;
    }

    /// Функция загрузки и обработки заочников.
    /// [map] - "Группа" - ["Ссылка"]
    Future<void> parseSchedulePages(Map<String, List<String>> map) async {
      int errorsCount = 0;
      for (var group in map.keys) {
        progress++;

        ///Если один из потоков сдох, то обрубать все
        if (globalErrorsCount > 0) break;

        try {
          final page = await repository.loadPage(map[group]![0]);

          String? groupName = RegExp(r'#ff00ff">.*</P').firstMatch(page)?[0];
          if (groupName != null) {
            groupName = groupName
                .replaceAll('#ff00ff">', '')
                .replaceAll('</P', '')
                .trim();
          }

          if (groupName != group) {
            warnings += 'Несовпадение назвний группы: $groupName - $group\n';
            continue;
          }

          final weekNames = <String>[];
          try {
            final mondays = RegExp('Пнд.*[а-я|А-Я]').allMatches(page);
            final sundays = RegExp('Вск.*[а-я|А-Я]').allMatches(page);

            for (int i = 0; i < mondays.length; i++) {
              weekNames.add('${dateFromZoDayOfWeek(mondays.elementAt(i)[0])} '
                  '- ${dateFromZoDayOfWeek(sundays.elementAt(i)[0])}');
            }
          } catch (e) {
            warnings += 'Невозможно определить дату недели: $group - $e\n';
            continue;
          }

          final splittedPage = page
              .replaceAll(' COLOR="#0000ff"', '')
              .split('SIZE=2><P ALIGN="CENTER">')
              .skip(1);

          int dayOfWeekIndex = 0;
          for (String dayOfWeek in splittedPage) {
            String? dayOfWeekDate;
            final lastIndex = dayOfWeek.indexOf('</B>');
            dayOfWeekDate = lastIndex > 0
                ? dateFromZoDayOfWeek(dayOfWeek.substring(0, lastIndex).trim())
                : null;

            if (dayOfWeekDate == null) {
              dayOfWeekIndex++;
              continue;
            }

            final lessons = dayOfWeek.split('"CENTER">').skip(1);

            int lessonIndex = 0;
            for (String lessonSection in lessons) {
              if (!lessonSection.contains('а.')) {
                lessonIndex++;
                continue;
              }

              final fullLesson =
                  '$group ${lessonSection.substring(0, lessonSection.indexOf('</FONT>')).trim()}';

              final lessonChecker =
                  fullLesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

              if (lessonChecker.isEmpty) {
                lessonIndex++;
                continue;
              }

              /// Приходится вытаскивать список пар по количеству аудиторий в
              /// ячейке пары группы
              final lessonsList = LessonBuilder.createZoClassroomLessons(
                  lessonNumber: lessonIndex + 1, lesson: fullLesson);

              for (var builtLesson in lessonsList) {
                final currentClassroom =
                    builtLesson.lessonData?[0][Lesson.classrooms];
                if (currentClassroom == null) continue;

                if (!currentClassroom.contains(RegExp(r"[0-9]"))) {
                  //if (++lessonIndex > 5) break;
                  continue;
                }

                /// Затирать, чтоб не отображалось лишнее поле
                builtLesson.lessonData?[0][Lesson.classrooms] = '';

                final building =
                    '${getBuildingByClassroom(currentClassroom)} корпус';
                final zoClassroom = ' $currentClassroom Заоч.';

                bool isScheduleExist = true;
                var currentScheduleModel = buildingsScheduleMap[building]
                    ?.firstWhereOrNull(
                        (element) => element.name == zoClassroom);

                if (currentScheduleModel == null) {
                  currentScheduleModel = ScheduleModel(
                    name: zoClassroom,
                    type: ScheduleType.classroom,
                    weeks: [],
                  );
                  isScheduleExist = false;
                }

                currentScheduleModel.updateWeekByDate(
                  weekNames[dayOfWeekIndex ~/ 7],
                  dayOfWeekIndex % 7,
                  lessonIndex,
                  builtLesson,
                  dayOfWeekDate: dayOfWeekDate,
                );

                if (!isScheduleExist && currentScheduleModel.isNotEmpty) {
                  buildingsScheduleMap[building]?.add(currentScheduleModel);
                }
              }

              if (++lessonIndex >= 7) break;
            }

            dayOfWeekIndex++;
          }
        } catch (e, stack) {
          Logger.error(
            title: Errors.pageLoadingError,
            exception: e,
            stack: stack,
          );
          errorsCount++;
        }

        if (errorsCount > 8) {
          globalErrorsCount++;
          break;
        }
      }

      completeThreads++;
    }

    /// Запуск [threadCount] асинхронных операций
    for (var map in threadsMaps) {
      parseSchedulePages(map);
    }

    /// Ожидание завершения всех потоков
    while (completeThreads < threadsCount) {
      streamController.add({
        'percents': (progress / linksCount * 100).toInt().toString(),
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }

    /// Если хотя бы один поток вернул больше 8 ошибок, то обрубать
    if (globalErrorsCount > 0) {
      lastError = Logger.error(
        title: Errors.zoClassroomsError,
        exception: 'Большое количество ошибок при загрузке страниц '
            'расписания заочных групп. globalErrorsCount > 1',
      );
      return null;
    }

    if (warnings.isNotEmpty) {
      Logger.warning(
        title: Errors.zoClassroomsError,
        exception: warnings,
      );
    }

    buildingsScheduleMap.removeWhere((key, value) => value.isEmpty);
    for (var building in buildingsScheduleMap.keys) {
      buildingsScheduleMap[building]!.sort((a, b) => a.name.compareTo(b.name));
    }

    if (buildingsScheduleMap.isEmpty) {
      lastError = Logger.error(
        title: Errors.zoClassroomsError,
        exception: 'Не найдено ни одного расписания заочных групп. '
            'buildingsScheduleMap.isEmpty',
      );
      return null;
    }

    return buildingsScheduleMap;
  }
}
