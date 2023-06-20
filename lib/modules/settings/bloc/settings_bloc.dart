import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:schedule/core/errors.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/modules/settings/settings_repository.dart';
import 'package:schedule/core/settings_types.dart';

part 'settings_state.dart';

part 'settings_event.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(SettingsRepository repository)
      : _settingsRepository = repository,
        super(SettingsState()) {
    on<LoadSettings>(_loadSettings);
    on<ChangeSetting>(_changeSetting);
    on<ClearAll>(_clearAll);
  }

  Future<void> _loadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final stringSettingsValues = await _settingsRepository.loadSettings();

      emit(
        SettingsLoaded(
          darkTheme: stringSettingsValues[SettingsTypes.darkTheme] == 'true',
          autoUpdate: stringSettingsValues[SettingsTypes.autoUpdate] == 'true',
          noUpdateClassroom:
              stringSettingsValues[SettingsTypes.noUpdateClassroom] == 'true',
        ),
      );
    } catch (e, stack) {
      emit(SettingsError(Logger.error(
        title: Errors.settingsError,
        exception: e,
        stack: stack,
      )));
    }
  }

  Future<void> _changeSetting(
      ChangeSetting event, Emitter<SettingsState> emit) async {
    try {
      final stringSettingsValues = await _settingsRepository.saveSettings(
          event.settingType, event.value);
      emit(
        SettingsLoaded(
          darkTheme: stringSettingsValues[SettingsTypes.darkTheme] == 'true',
          autoUpdate: stringSettingsValues[SettingsTypes.autoUpdate] == 'true',
          noUpdateClassroom:
              stringSettingsValues[SettingsTypes.noUpdateClassroom] == 'true',
        ),
      );
    } catch (e, stack) {
      emit(SettingsError(Logger.error(
        title: Errors.settingsError,
        exception: e,
        stack: stack,
      )));
    }
  }

  Future<void> _clearAll(ClearAll event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await _settingsRepository.clearAll();

    try {
      final stringSettingsValues = await _settingsRepository.loadSettings();

      emit(
        SettingsLoaded(
          darkTheme: stringSettingsValues[SettingsTypes.darkTheme] == 'true',
          autoUpdate: stringSettingsValues[SettingsTypes.autoUpdate] == 'true',
          noUpdateClassroom:
              stringSettingsValues[SettingsTypes.noUpdateClassroom] == 'true',
        ),
      );
    } catch (e, stack) {
      emit(SettingsError(Logger.error(
        title: Errors.settingsError,
        exception: e,
        stack: stack,
      )));
    }
  }
}
