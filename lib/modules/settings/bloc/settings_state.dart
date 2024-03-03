part of 'settings_bloc.dart';

class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkTheme;
  final bool autoUpdate;
  final bool hideSchedule;
  final bool hideLesson;
  final bool showTabDate;

  final bool noUpdateClassroom;
  final bool weekButtonHint;

  SettingsLoaded({
    required this.darkTheme,
    required this.autoUpdate,
    required this.noUpdateClassroom,
    required this.hideSchedule,
    required this.showTabDate,
    required this.hideLesson,
    required this.weekButtonHint,
  });
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
