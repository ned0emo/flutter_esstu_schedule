import 'package:flutter_secure_storage/flutter_secure_storage.dart';

///Для сохранения включенных настроек записывать в файл строку ['true']
///
/// Для выключенных соответственно ['false']
class SettingsRepository {
  final storage = const FlutterSecureStorage();

  /// Первая строка - горизонтальная прокрутка
  ///
  /// Вторая вторая - темная тема
  ///
  /// Третья строка - автообновление
  ///
  /// По усолчанию - ['true'] ['false'] ['true']
  final List<String> settingsList = ['true', 'false', 'true'];

  Future<List<String>> loadSettings() async {
    settingsList[0] =
        await storage.read(key: 'horizontalSwipeSetting') ?? 'true';
    settingsList[1] = await storage.read(key: 'darkThemeSetting') ?? 'false';
    settingsList[2] = await storage.read(key: 'autoUpdateSetting') ?? 'true';

    return settingsList;
  }

  Future<void> saveSettings({
    required List<bool?> settingsListForSave,
  }) async {
    settingsListForSave[0] ??
        await storage.write(
          key: 'horizontalSwipeSetting',
          value: settingsListForSave[0].toString(),
        );

    settingsListForSave[1] ??
        await storage.write(
          key: 'darkThemeSetting',
          value: settingsListForSave[1].toString(),
        );

    settingsListForSave[2] ??
        await storage.write(
          key: 'autoUpdateSetting',
          value: settingsListForSave[2].toString(),
        );
  }
}
