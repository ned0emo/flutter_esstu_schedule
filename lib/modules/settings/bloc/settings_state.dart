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
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkTheme;
  final bool autoUpdate;

  SettingsLoaded({required this.darkTheme, required this.autoUpdate});

  String get darkThemeDescription =>
      darkTheme ? _darkThemeEnableDescription : _darkThemeDisableDescription;

  String get autoUpdateDescription =>
      autoUpdate ? _autoUpdateEnableDescription : _autoUpdateDisableDescription;
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
