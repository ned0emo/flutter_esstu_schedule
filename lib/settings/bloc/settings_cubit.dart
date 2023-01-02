import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/settings/bloc/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const int horizontalSwipe = 0;
  static const int darkTheme = 1;
  static const int autoUpdate = 2;

  final List<bool> settingsList = [true, false, true];
  final SettingsRepository repository;

  SettingsCubit({
    required this.repository,
  }) : super(
          SettingsState(
            horizontalSwipe: true,
            darkTheme: false,
            autoUpdate: true,
          ),
        );

  Future<void> loadSettings() async {
    final stringSettingsValues = await repository.loadSettings();
    for (int i = 0; i < stringSettingsValues.length; i++) {
      stringSettingsValues[i] == 'true'
          ? settingsList[i] = true
          : settingsList[i] = false;
    }

    emit(
      SettingsState(
        horizontalSwipe: settingsList[horizontalSwipe],
        darkTheme: settingsList[darkTheme],
        autoUpdate: settingsList[autoUpdate],
      ),
    );
  }

  ///типы настроек ([settingType]) заданы статическими полями в классе [SettingsCubit]
  Future<void> changeSetting({
    required int settingType,
    required bool settingValue,
  }) async {
    final List<bool?> listForSaving = [null, null, null];
    listForSaving[settingType] = settingValue;

    await repository.saveSettings(settingsListForSave: listForSaving);
    settingsList[settingType] = settingValue;

    emit(
      SettingsState(
        horizontalSwipe: settingsList[horizontalSwipe],
        darkTheme: settingsList[darkTheme],
        autoUpdate: settingsList[autoUpdate],
      ),
    );
  }
}
