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
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkTheme;
  final bool autoUpdate;
  final bool noUpdateClassroom;
  final bool hideSchedule;

  SettingsLoaded({
    required this.darkTheme,
    required this.autoUpdate,
    required this.noUpdateClassroom,
    required this.hideSchedule,
  });

  String get darkThemeDescription =>
      darkTheme ? _darkThemeEnableDescription : _darkThemeDisableDescription;

  String get autoUpdateDescription =>
      autoUpdate ? _autoUpdateEnableDescription : _autoUpdateDisableDescription;

  String get hideScheduleDescription =>
      hideSchedule ? _hideScheduleEnableDescription : _hideScheduleDisableDescription;
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
