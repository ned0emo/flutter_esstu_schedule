import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/time/current_time.dart';
import 'package:schedule/core/logger/errors.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/modules/settings/settings_repository.dart';

part 'settings_event.dart';

part 'settings_state.dart';

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

      ///
      /// загрузка сдвига номера недели
      ///
      if (stringSettingsValues[SettingsTypes.weekIndexShifting] == 'true') {
        CurrentTime.weekShifting = 1;
      }

      emit(
        SettingsLoaded(
          darkTheme: stringSettingsValues[SettingsTypes.darkTheme] == 'true',
          autoUpdate: stringSettingsValues[SettingsTypes.autoUpdate] == 'true',
          noUpdateClassroom:
              stringSettingsValues[SettingsTypes.noUpdateClassroom] == 'true',
          hideSchedule:
              stringSettingsValues[SettingsTypes.hideSchedule] == 'true',
          hideLesson: stringSettingsValues[SettingsTypes.hideLesson] == 'true',
          weekButtonHint:
              stringSettingsValues[SettingsTypes.weekButtonHint] == 'true',
          showTabDate:
              stringSettingsValues[SettingsTypes.showTabDate] == 'true',
        ),
      );
    } catch (e, stack) {
      emit(SettingsError('${Errors.settings}: ${e.runtimeType}\n$stack'));
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
          hideSchedule:
              stringSettingsValues[SettingsTypes.hideSchedule] == 'true',
          hideLesson: stringSettingsValues[SettingsTypes.hideLesson] == 'true',
          weekButtonHint:
              stringSettingsValues[SettingsTypes.weekButtonHint] == 'true',
          showTabDate:
              stringSettingsValues[SettingsTypes.showTabDate] == 'true',
        ),
      );
    } catch (e, stack) {
      emit(SettingsError('${Errors.settings}: ${e.runtimeType}\n$stack'));
    }
  }

  Future<void> _clearAll(ClearAll event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      await _settingsRepository.clearAll();
    } catch (e, stack) {
      emit(SettingsError('${Errors.settings}: ${e.runtimeType}\n$stack'));
      return;
    }

    try {
      final stringSettingsValues = await _settingsRepository.loadSettings();

      emit(
        SettingsLoaded(
          darkTheme: stringSettingsValues[SettingsTypes.darkTheme] == 'true',
          autoUpdate: stringSettingsValues[SettingsTypes.autoUpdate] == 'true',
          noUpdateClassroom:
              stringSettingsValues[SettingsTypes.noUpdateClassroom] == 'true',
          hideSchedule:
              stringSettingsValues[SettingsTypes.hideSchedule] == 'true',
          hideLesson: stringSettingsValues[SettingsTypes.hideLesson] == 'true',
          weekButtonHint:
              stringSettingsValues[SettingsTypes.weekButtonHint] == 'true',
          showTabDate:
              stringSettingsValues[SettingsTypes.showTabDate] == 'true',
        ),
      );
    } catch (e, stack) {
      emit(SettingsError('${Errors.settings}: ${e.runtimeType}\n$stack'));
    }
  }
}
