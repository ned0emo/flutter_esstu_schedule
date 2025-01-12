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
  final bool weekIndexShifting;
  final bool autoWeekIndexSet;

  final bool noUpdateClassroom;
  final bool weekButtonHint;

  final int sdkVersion;

  SettingsLoaded({
    required this.darkTheme,
    required this.autoUpdate,
    required this.noUpdateClassroom,
    required this.hideSchedule,
    required this.showTabDate,
    required this.hideLesson,
    required this.weekButtonHint,
    required this.autoWeekIndexSet,
    required this.weekIndexShifting,
    required this.sdkVersion,
  });

  static SettingsLoaded fromMap(Map<String, String> settingsMap, int sdkVersion) =>
      SettingsLoaded(
        darkTheme: settingsMap[SettingsTypes.darkTheme] == 'true',
        autoUpdate: settingsMap[SettingsTypes.autoUpdate] == 'true',
        noUpdateClassroom:
            settingsMap[SettingsTypes.noUpdateClassroom] == 'true',
        hideSchedule: settingsMap[SettingsTypes.hideSchedule] == 'true',
        hideLesson: settingsMap[SettingsTypes.hideLesson] == 'true',
        weekButtonHint: settingsMap[SettingsTypes.weekButtonHint] == 'true',
        showTabDate: settingsMap[SettingsTypes.showTabDate] == 'true',
        autoWeekIndexSet: settingsMap[SettingsTypes.autoWeekIndexSet] == 'true',
        weekIndexShifting:
            settingsMap[SettingsTypes.weekIndexShifting] == 'true',
        sdkVersion: sdkVersion,
      );
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
