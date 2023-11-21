import 'dart:async';

import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/schedule_links.dart';
import 'package:schedule/core/static/students_type.dart';

class StudentsParser {
  final MainRepository _repository;

  String? lastError;

  StudentsParser(MainRepository repository) : _repository = repository;

  ///Мэп группа - ссылка по курсам
  Future<Map<String, Map<String, Map<String, String>>>?>
      courseGroupLinkMap() async {
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
        schedulePages.add(await _repository.loadPage(link));
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
  Future<Map<String, List<String>>?> groupLinkMap() async {
    final schedulePages = <String>[];

    final studentsLinks = [
      ScheduleLinks.allBakGroups,
      ScheduleLinks.allMagGroups,
      ScheduleLinks.allZo1Groups,
      ScheduleLinks.allZo2Groups,
    ];

    final Map<String, List<String>> scheduleLinksMap = {};

    try {
      for (String link in studentsLinks) {
        schedulePages.add(await _repository.loadPage(link));
      }

      _parseStudentGroups(scheduleLinksMap, schedulePages,
          (map, name, link, type, i) {
        map[name] ??= [];
        map[name]!.add(link);
      });

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
  /// [schedulePages] - список ссылок на страницы с учебными группами
  /// [mapCreating] - функция для заполнения переданного мэпа
  void _parseStudentGroups<T extends Map>(
    T map,
    List<String> schedulePages,
    void Function(T map, String name, String link, String type, int j)
        mapCreating,
  ) async {
    final studentsScheduleLinks = [
      ScheduleLinks.bakPrefix,
      ScheduleLinks.magPrefix,
      ScheduleLinks.zo1Prefix,
      ScheduleLinks.zo2Prefix,
    ];

    final studentsTypes = [
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
}
