part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

/// Не использовать после первой инициализации в AppWidget
///
/// Ломается маршрутизация
class InitialLoadSettings extends SettingsEvent {}

class ChangeSetting extends SettingsEvent {
  final String settingType;
  final String value;

  ChangeSetting({required this.settingType, required this.value});
}

class ClearAll extends SettingsEvent {}
