import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/core/time/current_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  Future<Map<String, String>> loadSettings() async {
    final storage = await SharedPreferences.getInstance();

    final Map<String, String> settingsMap = {
      SettingsTypes.autoUpdate:
          (storage.getString(SettingsTypes.autoUpdate)) ?? 'true',
      SettingsTypes.darkTheme:
          (storage.getString(SettingsTypes.darkTheme)) ?? 'false',
      SettingsTypes.noUpdateClassroom:
          (storage.getString(SettingsTypes.noUpdateClassroom)) ?? 'false',
      SettingsTypes.hideSchedule:
          (storage.getString(SettingsTypes.hideSchedule)) ?? 'false',
      SettingsTypes.hideLesson:
          (storage.getString(SettingsTypes.hideLesson)) ?? 'false',
      SettingsTypes.weekButtonHint:
          (storage.getString(SettingsTypes.weekButtonHint)) ?? 'false',
      SettingsTypes.showTabDate:
          (storage.getString(SettingsTypes.showTabDate)) ?? 'true',
      SettingsTypes.weekIndexShifting:
          (storage.getString(SettingsTypes.weekIndexShifting)) ?? 'false'
    };

    return settingsMap;
  }

  Future<Map<String, String>> saveSettings(String type, String value) async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString(type, value);

    return await loadSettings();
  }

  Future<void> clearAll() async {
    final storage = await SharedPreferences.getInstance();
    await storage.clear();
    CurrentTime.weekShifting = 0;
  }

  Future<void> clearFavorite() async {
    final storage = await SharedPreferences.getInstance();
    final list = storage.getKeys();
    list.removeWhere(
        (key) => key.contains('Service') && !key.contains('MainFavService'));

    for (var key in list) {
      storage.remove(key);
    }
  }
}
