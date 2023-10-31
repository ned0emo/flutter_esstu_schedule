import 'package:jiffy/jiffy.dart';

class ScheduleTimeData {
  static final List<String> lessonTimeList = [
    '9:00 - 10:35',
    '10:45 - 12:20',
    '13:00 - 14:35',
    '14:45 - 16:20',
    '16:25 - 18:00',
    '18:05 - 19:40',
    '19:45 - 21:20',
  ];

  static final daysOfWeek = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  static final daysOfWeekSmall = [
    'ПН',
    'ВТ',
    'СР',
    'ЧТ',
    'ПТ',
    'СБ',
    'ВС',
  ];

  /// Индекс текущей пары, начиная с нуля. Если сейчас пары нет, то -1
  static int getCurrentLessonIndex() {
    int currentLesson = -1;
    final currentTime = Jiffy.now().dateTime.minute + Jiffy.now().dateTime.hour * 60;
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

    return currentLesson;
  }

  /// Индекс текущей недели, начиная с нуля
  static int getCurrentWeekIndex() => (Jiffy.now().weekOfYear + 1) % 2;

  /// Индекс текущего дня недели, начиная с нуля
  static int getCurrentDayOfWeekIndex() => Jiffy.now().dateTime.weekday - 1;
}
