import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/schedule_links.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/students_type.dart';

class Parser {
  final MainRepository _repository;

  String? lastError;

  Parser(MainRepository repository) : _repository = repository;

  Future<Map<String, Map<String, Map<String, String>>>?> courseGroupMap() async {
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

      if (scheduleMap.isEmpty) return null;

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

  Future<Map<String, List<String>>?> groupMap() async {
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

      return scheduleLinksMap.isNotEmpty ? scheduleLinksMap : null;
    } catch (e, stack) {
      lastError = Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      );
    }

    return null;
  }

  void _parseStudentGroups<T extends Map>(
    T map,
    List<String> schedulePages,
    void Function(T map, String name, String link, String type, int j) function,
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

        function(map, name, link, studentsTypes[i], j++);
      }
      i++;
    }
  }

  Future<ScheduleModel?> getScheduleModel({
    required String link1,
    String? link2,
    String? page1,
    String? page2,
    required String scheduleName,
    required String scheduleType,
    bool isZo = false,
  }) async {
    final numOfLessons = isZo ? 7 : 6;

    final pagesList = <String>[];
    try {
      pagesList.add(page1 ?? await _repository.loadPage(link1));
      if (page2 != null) {
        pagesList.add(page2);
      } else if (link2 != null) {
        pagesList.add(await _repository.loadPage(link2));
      }
    } catch (e, stack) {
      lastError = Logger.error(
        title: Errors.pageLoadingError,
        exception: e,
        stack: stack,
      );

      return null;
    }

    final ScheduleModel scheduleModel = ScheduleModel(
      name: scheduleName,
      type: scheduleType,
      weeks: [],
      link1: link1,
      link2: link2,
    );

    try {
      for (String page in pagesList) {
        final scheduleBeginning = scheduleType == ScheduleType.teacher
            ? page.split(scheduleName).elementAt(1)
            : page;

        final splittedPage = scheduleType == ScheduleType.teacher
            ? scheduleBeginning
                .substring(0, scheduleBeginning.indexOf('</TABLE>'))
                .replaceAll(' COLOR="#0000ff"', '')
                .split('SIZE=2><P ALIGN="CENTER">')
                .skip(1)
            : scheduleBeginning
                .replaceAll(' COLOR="#0000ff"', '')
                .split('SIZE=2><P ALIGN="CENTER">')
                .skip(1);

        int dayOfWeekIndex = 0;
        for (String dayOfWeek in splittedPage) {
          String? dayOfWeekDate;
          if (isZo) {
            final lastIndex = dayOfWeek.indexOf('</B>');
            dayOfWeekDate = lastIndex > 0
                ? _dateFromZoDayOfWeek(dayOfWeek.substring(0, lastIndex).trim())
                : null;
          }
          final lessons = dayOfWeek.split('"CENTER">').skip(1);

          int lessonIndex = 0;
          for (String lessonSection in lessons) {
            final lesson = lessonSection
                .substring(0, lessonSection.indexOf('</FONT>'))
                .trim();

            final lessonChecker =
                lesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

            if (lessonChecker.isEmpty) {
              if (++lessonIndex >= numOfLessons) break;
              continue;
            }

            scheduleModel.updateWeek(
              dayOfWeekIndex ~/ numOfLessons,
              dayOfWeekIndex % numOfLessons,
              lessonIndex,
              scheduleType == ScheduleType.teacher
                  ? LessonBuilder.createTeacherLesson(
                      lessonNumber: lessonIndex + 1,
                      lesson: lesson,
                    )
                  : LessonBuilder.createStudentLesson(
                      lessonNumber: lessonIndex + 1,
                      lesson: lesson,
                    ),
              dayOfWeekDate: dayOfWeekDate,
            );

            if (++lessonIndex >= numOfLessons) break;
          }

          dayOfWeekIndex++;
        }
      }

      return scheduleModel;
    } catch (e, stack) {
      lastError = Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      );

      return null;
    }
  }

  String? _dateFromZoDayOfWeek(String? dayOfWeek) {
    if (dayOfWeek == null) return null;

    final splittedDayOfWeek = dayOfWeek.split(RegExp(r'\s+'));
    if (splittedDayOfWeek.length < 2) return null;

    final day = splittedDayOfWeek[0].contains(',')
        ? splittedDayOfWeek[0].split(',')[1]
        : splittedDayOfWeek[0];

    final month = splittedDayOfWeek[1];
    if (month.contains('янв') || month.contains('ЯНВ')) {
      return '$day.01';
    }
    if (month.contains('фев') || month.contains('ФЕВ')) {
      return '$day.02';
    }
    if (month.contains('мар') || month.contains('МАР')) {
      return '$day.03';
    }
    if (month.contains('апр') || month.contains('АПР')) {
      return '$day.04';
    }
    if (month.contains('мая') ||
        month.contains('МАЯ') ||
        month.contains('май') ||
        month.contains('МАЙ')) {
      return '$day.05';
    }
    if (month.contains('июн') || month.contains('ИЮН')) {
      return '$day.06';
    }
    if (month.contains('июл') || month.contains('ИЮЛ')) {
      return '$day.07';
    }
    if (month.contains('авг') || month.contains('АВГ')) {
      return '$day.08';
    }
    if (month.contains('сен') || month.contains('СЕН')) {
      return '$day.09';
    }
    if (month.contains('окт') || month.contains('ОКТ')) {
      return '$day.10';
    }
    if (month.contains('ноя') || month.contains('НОЯ')) {
      return '$day.11';
    }
    if (month.contains('дек') || month.contains('ДЕК')) {
      return '$day.12';
    }

    return null;
  }
}
