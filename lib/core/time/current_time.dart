import 'package:jiffy/jiffy.dart';

abstract final class CurrentTime {
  static int get weekIndex => (Jiffy.now().weekOfYear + weekShifting) % 2;

  static int get weekNumber => weekIndex + 1;

  static int weekShifting = 0;

  static int get dayOfWeekIndex => Jiffy.now().dayOfWeek - 1;

  static int get minuteOfDay =>
      Jiffy.now().dateTime.minute + Jiffy.now().dateTime.hour * 60;
}
