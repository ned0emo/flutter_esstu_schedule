import 'dart:async';

import 'package:schedule/core/parser/parser.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/schedule_links.dart';
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

  ///Просто мэп группа - ссылка
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

  /*/// Создание мэпа корпус - список аудиторий.
  /// [streamController] - для отслеживания прогресса в блоке, после окончания
  /// обязательно закрывать
  Future<Map<String, List<ScheduleModel>>?> buildingsClassroomsMap(
      StreamController<Map<String, String>> streamController) async {
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

    final studentsScheduleLinks = [
      ScheduleLinks.zo1Prefix,
      //ScheduleLinks.zo2Prefix,
    ];

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

    final pagesList = [
      await repository.loadPage(ScheduleLinks.allZo1Groups),
      //await repository.loadPage(ScheduleLinks.allZo2Groups),
    ];

    final groupLinkMap = await this.groupLinkMap(defaultStudentsLinks: [
      ScheduleLinks.zo1Prefix,
      //ScheduleLinks.zo2Prefix,
    ], defaultScheduleLinks: [
      ScheduleLinks.zo1Prefix,
      //ScheduleLinks.zo2Prefix,
    ], defaultStudentsTypes: [
      StudentsType.zo1,
    ]);

    if(groupLinkMap == null) return null;

    for (var pair in groupLinkMap) {
      final page = await repository.loadPage(link);

      String? groupName = RegExp(r'#ff00ff">.*</P').firstMatch(page)?[0];
      if (groupName != null) {
        groupName =
            groupName.replaceAll('#ff00ff">', '').replaceAll('</P', '').trim();
      }
      final teacherName =
          teacherSection.substring(0, teacherSection.indexOf('</P>')).trim();

      final daysOfWeekFromPage =
          teacherSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

      int dayOfWeekIndex = 0;
      for (String dayOfWeek in daysOfWeekFromPage) {
        final lessons = dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

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

          final building = '${getBuildingByClassroom(classroom)} корпус';

          bool isScheduleExist = true;
          var currentScheduleModel = map[building]
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
            map[building]?.add(currentScheduleModel);
          }

          if (++lessonIndex > 5) break;
        }

        if (++dayOfWeekIndex > 11) break;
      }
    }

    return null;
  }

   */
}
