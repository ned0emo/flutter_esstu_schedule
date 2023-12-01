part of 'settings_bloc.dart';

class SettingsState {
  final String _darkThemeEnableDescription =
      'Интерфейс приложения оформлен в темных цветах';
  final String _darkThemeDisableDescription =
      'Интерфейс приложения оформлен в светлых цветах';

  final String _autoUpdateEnableDescription =
      'Расписание в избранном будет проверять обновления автоматически при открытии';
  final String _autoUpdateDisableDescription =
      'Расписание в избранном не будет проверять обновления автоматически';

  final String _hideScheduleEnableDescription =
      'Дни недели без занятий будут скрыты';
  final String _hideScheduleDisableDescription =
      'Будут отображены все дни недели';

  final String _hideLessonEnableDescription =
      'Пустые занятия будут скрыты';
  final String _hideLessonDisableDescription =
      'Пустые занятия будут отображены';
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkTheme;
  final bool autoUpdate;
  final bool noUpdateClassroom;
  final bool hideSchedule;
  final bool hideLesson;

  SettingsLoaded({
    required this.darkTheme,
    required this.autoUpdate,
    required this.noUpdateClassroom,
    required this.hideSchedule,
    required this.hideLesson,
  });

  String get darkThemeDescription =>
      darkTheme ? _darkThemeEnableDescription : _darkThemeDisableDescription;

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
