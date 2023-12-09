import 'package:schedule/core/models/lesson_model.dart';

class LessonBuilder {
  static const teachersRegExp =
      r'[А-Я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.\s*[А-Я]\.|[А-Я]+\s+[А-Я]\.|[А-Я][а-я]+\s+[А-Я]\.';
  static const classroomsJunkRegExp =
      r'и/д-*|д/кл-*|д/к-*|н/х-*|\s+мф\s+|\s+и/п\s+|\s+св\s+|\s+си\s+|смук-*';
  static const classroomsRegExp = r'(?:\s*а\.\s*\S+\s*)+';
  static const oneClassroomRegExp = r'а\.\s*\S+';

  //static const groupsRegExp = r'(?:\s*а\.\s*\S+\s*)+';

  static Lesson createStudentLesson({
    required int lessonNumber,
    required String lesson,
  }) {
    final clearLesson = lesson.replaceAll(RegExp(classroomsJunkRegExp), ' ');

    final List<Map<String, String>> lessonData = [];

    final lessons = clearLesson.split(RegExp(classroomsRegExp));
    if (lessons.length > 1) lessons.removeLast();

    final classrooms = RegExp(classroomsRegExp)
        .allMatches(clearLesson)
        .map((e) =>
            e[0]
                ?.replaceAll(RegExp(r'а\.\s*'), '')
                .trim()
                .replaceAll(RegExp(r'-?\s+'), ', ')
                .replaceAll(RegExp(r',\s$'), '') ??
            '')
        .toList();

    for (int i = 0; i < lessons.length; i++) {
      final teachers =
          RegExp(teachersRegExp).allMatches(lessons[i]).map((e) => e[0] ?? '');

      String title = _lessonTitle(lessons[i]);
      if (title.length < 3 && i > 0) {
        title = lessonData[i - 1]['title'] ?? 'Ошибка';
      }

      String type = _lessonType(lessons[i]);
      if (type == 'Другое' && i > 0) {
        type = lessonData[0][Lesson.type] ?? type;
      }

      lessonData.add({
        Lesson.title: title,
        Lesson.teachers: teachers.join(', '),
        Lesson.classrooms: i < classrooms.length ? classrooms[i] : '',
        Lesson.type: type
      });
    }

    return Lesson(
      lessonNumber: lessonNumber,
      lessonData: lessonData,
      fullLesson: lesson,
    );
    /*RegExp(teachersRegExp)
        .allMatches(clearLesson)
        .map((e) => e[0] ?? '')
        .toList();*/
  }

  static Lesson createZoClassroomLesson({
    required int lessonNumber,
    required String lesson,
  }) {
    final clearLesson = lesson.replaceAll(RegExp(classroomsJunkRegExp), ' ');

    final List<Map<String, String>> lessonData = [];

    final lessons = clearLesson.split(RegExp(classroomsRegExp));
    if (lessons.length > 1) lessons.removeLast();

    for (int i = 0; i < lessons.length; i++) {
      final teachers =
      RegExp(teachersRegExp).allMatches(lessons[i]).map((e) => e[0] ?? '');

      String title = _lessonTitle(lessons[i]);
      if (title.length < 3 && i > 0) {
        title = lessonData[i - 1]['title'] ?? 'Ошибка';
      }

      String type = _lessonType(lessons[i]);
      if (type == 'Другое' && i > 0) {
        type = lessonData[0][Lesson.type] ?? type;
      }

      lessonData.add({
        Lesson.title: title,
        Lesson.teachers: teachers.join(', '),
        Lesson.type: type
      });
    }

    return Lesson(
      lessonNumber: lessonNumber,
      lessonData: lessonData,
      fullLesson: lesson,
    );
    /*RegExp(teachersRegExp)
        .allMatches(clearLesson)
        .map((e) => e[0] ?? '')
        .toList();*/
  }

  static Lesson createTeacherLesson({
    required int lessonNumber,
    required String lesson,
  }) {
    final clearLesson = lesson.replaceAll(RegExp(classroomsJunkRegExp), ' ');

    return Lesson(
      lessonNumber: lessonNumber,
      lessonData: [
        {
          Lesson.title: _lessonTitle(clearLesson),
          Lesson.classrooms: RegExp(oneClassroomRegExp)
                  .firstMatch(clearLesson)?[0]
                  ?.replaceAll(RegExp(r'а\.\s*'), '')
                  .trim() ??
              '',
          Lesson.type: _lessonType(clearLesson)
        }
      ],
      fullLesson: lesson,
    );
  }

  static Lesson createClassroomLesson({
    required int lessonNumber,
    required String lesson,
  }) {
    //final clearLesson = lesson.replaceAll(RegExp(classroomsJunkRegExp), '');
    final teacher = RegExp(teachersRegExp).firstMatch(lesson)?[0] ?? '';

    return Lesson(
      lessonNumber: lessonNumber,
      lessonData: [
        {
          Lesson.title: _lessonTitle(lesson),
          Lesson.teachers: teacher,
          Lesson.type: _lessonType(lesson)
        }
      ],
      fullLesson: lesson,
    );
  }

  static String _lessonTitle(String lesson) {
    return lesson
        //приписки аудиторий
        .replaceAll(RegExp(classroomsJunkRegExp), '')
        //препод
        .replaceAll(RegExp(teachersRegExp), '')
        //тип занятия
        .replaceAll(RegExp(r'лек\.|пр\.|лаб\.|экз\.'), '')
        //аудитории
        .replaceAll(RegExp(r'а\.\s*\S+'), '')
        //Лишние символы в конце (также пустое занятие)
        .replaceAll(RegExp(r'[^а-яА-Я0-9a-zA-Z)]+$'), '')
        //много точек
        .replaceAll(RegExp(r'\.{2,}'), '.')
        //длинные пробелы
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  static String _lessonType(String lesson) {
    if (lesson.isEmpty) return '';

    final lType =
        RegExp(r'лек\.|пр\.|лаб\.|ЭК по ФКС|Физическая культура|экз\.|Лаборато')
            .firstMatch(lesson)?[0];
    switch (lType) {
      case 'лек.':
        return 'Лекция';
      case 'пр.':
        return 'Практика';
      case 'лаб.':
        return 'Лабораторная';
      case 'Лаборато':
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
