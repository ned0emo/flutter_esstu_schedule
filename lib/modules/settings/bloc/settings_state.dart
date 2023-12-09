part of 'settings_bloc.dart';

class SettingsState {
  final String _autoUpdateEnableDescription =
      'Расписание в избранном проверяет обновления автоматически при открытии';
  final String _autoUpdateDisableDescription =
      'Расписание в избранном не проверяет обновления автоматически';

  final String _hideScheduleEnableDescription =
      'Дни недели без занятий скрыты';
  final String _hideScheduleDisableDescription =
      'Отображены все дни недели';

  final String _hideLessonEnableDescription =
      'Пустые занятия скрыты';
  final String _hideLessonDisableDescription =
      'Пустые занятия отображены';
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkTheme;
  final bool autoUpdate;
  final bool hideSchedule;
  final bool hideLesson;

  final bool noUpdateClassroom;
  final bool weekButtonHint;

  SettingsLoaded({
    required this.darkTheme,
    required this.autoUpdate,
    required this.noUpdateClassroom,
    required this.hideSchedule,
    required this.hideLesson,
    required this.weekButtonHint,
  });

  String get autoUpdateDescription =>
      autoUpdate ? _autoUpdateEnableDescription : _autoUpdateDisableDescription;

  String get hideScheduleDescription =>
      hideSchedule ? _hideScheduleEnableDescription : _hideScheduleDisableDescription;

  String get hideLessonDescription =>
      hideLesson ? _hideLessonEnableDescription : _hideLessonDisableDescription;
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
