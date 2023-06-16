import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:schedule/core/settings_types.dart';

class SettingsRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> loadSettings() async {
    final Map<String, String> settingsMap = {
      SettingsTypes.autoUpdate: await _storage.read(key: SettingsTypes.autoUpdate) ?? 'true',
      SettingsTypes.darkTheme: await _storage.read(key: SettingsTypes.darkTheme) ?? 'false',
    };

    return settingsMap;
  }

  Future<Map<String, String>> saveSettings(String type, String value) async {
    await _storage.write(key: type, value: value);

    return await loadSettings();
  }
}
