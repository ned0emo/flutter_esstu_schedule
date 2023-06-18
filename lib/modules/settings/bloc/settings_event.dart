part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ChangeSetting extends SettingsEvent {
  final String settingType;
  final String value;

  ChangeSetting({required this.settingType, required this.value});
}

class ClearAll extends SettingsEvent{}
