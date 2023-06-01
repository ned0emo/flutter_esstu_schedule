class ScheduleType {
  static const classroom = 'classroom';
  static const student = 'student';
  static const teacher = 'teacher';

  static String scheduleTypeRussian(String type) {
    switch (type) {
      case classroom:
        return 'Аудитории';
      case student:
        return 'Учебные группы';
      case teacher:
        return 'Преподаватели';
      default:
        return 'Не распознано';
    }
  }
}
