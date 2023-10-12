import 'package:schedule/core/models/lesson_model.dart';

class LessonBuilder {
  static Lesson createLessonIfTitleLonger(
    Lesson oldLesson,
    String fullLesson, {
    String? title,
    String? type,
    List<String>? teachers,
    List<String>? groups,
    List<String>? classrooms,
  }) {
    final lessonChecker = fullLesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

    if (lessonChecker.isEmpty ||
        oldLesson.fullLesson.length > fullLesson.length) return oldLesson;

    return Lesson(
      lessonNumber: oldLesson.lessonNumber,
      fullLesson: fullLesson,
      title: title ?? _lessonTitle(fullLesson),
      teachers: teachers ?? _teacherNames(fullLesson),
      type: type ?? _lessonType(fullLesson),
    );
  }

  static Lesson createLesson(
    int lessonNumber,
    String fullLesson, {
    String? title,
    String? type,
    List<String>? teachers,
    List<String>? groups,
    List<String>? classrooms,
  }) {
    final lessonChecker = fullLesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

    return Lesson(
      lessonNumber: lessonNumber,
      fullLesson: lessonChecker.isEmpty ? lessonChecker : fullLesson,
      title: title ?? _lessonTitle(fullLesson),
      teachers: teachers ?? _teacherNames(fullLesson),
      type: type ?? _lessonType(fullLesson),
    );
  }

  static String _lessonTitle(String lesson) {
    return lesson
        //приписки аудиторий
        .replaceAll(RegExp(r'и/д|д/кл|д/к|н/х'), '')
        //препод
        .replaceAll(
            RegExp(
                r'[А-Я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я]+\s+[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.'),
            '')
        //тип занятия
        .replaceAll(RegExp(r'лек\.|пр\.|лаб\.|ЭК по ФКС|экз\.|'), '')
        //остатки аудитории в расписании аудиторий
        .replaceAll('а. ', '')
        //длинные пробелы
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        //много точек
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .trim();
  }

  static List<String> _teacherNames(String lesson) {
    return RegExp(
            r'[А-Я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я]+\s+[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.')
        .allMatches(lesson)
        .map((e) => e[0] ?? '')
        .toList();
  }

  static String _lessonType(String lesson) {
    if (lesson.isEmpty) return '';

    final lType =
        RegExp(r'лек\.|пр\.|лаб\.|ЭК по ФКС|Физическая культура|экз\.')
            .firstMatch(lesson)?[0];
    switch (lType) {
      case 'лек.':
        return 'Лекция';
      case 'пр.':
        return 'Практика';
      case 'лаб.':
        return 'Лабораторная';
      case 'ЭК по ФКС':
        return 'Физическая культура';
      case 'Физическая культура':
        return 'Физическая культура';
      case 'экз.':
        return 'Экзамен';
      default:
        return 'Другое';
    }
  }
}
