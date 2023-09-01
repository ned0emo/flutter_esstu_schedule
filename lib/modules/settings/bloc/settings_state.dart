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
  final String _lessonColorDescription =
      'Рядом с типом занятия будет показана цветная полоса';
  final String _lessonColorDisableDescription =
      'Тип занятия будет представлен только текстом';
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkTheme;
  final bool autoUpdate;
  final bool noUpdateClassroom;
  final bool hideSchedule;
  final bool lessonColor;

  SettingsLoaded({
    required this.darkTheme,
    required this.autoUpdate,
    required this.noUpdateClassroom,
    required this.hideSchedule,
    required this.lessonColor,
  });

  String get darkThemeDescription =>
      darkTheme ? _darkThemeEnableDescription : _darkThemeDisableDescription;

  String get autoUpdateDescription =>
      autoUpdate ? _autoUpdateEnableDescription : _autoUpdateDisableDescription;

  String get lessonColorDescription =>
      lessonColor ? _lessonColorDescription : _lessonColorDisableDescription;
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
