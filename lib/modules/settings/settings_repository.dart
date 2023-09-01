import 'package:schedule/core/settings_types.dart';
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
      SettingsTypes.lessonColor:
          (storage.getString(SettingsTypes.lessonColor)) ?? 'true',
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
  }
}
