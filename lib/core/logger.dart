import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

/// | - Разделитель данных сообщения
///
/// !! - Разделитель сообщений
class Logger {
  static String error = 'error';
  static String warning = 'warning';
  static String info = 'info';

  static const String _key = 'logService';
  static const _storage = FlutterSecureStorage();

  static Future<void> addLog(String type, String title, String message) async {
    final currentLog = await _storage.read(key: _key);
    final now = DateFormat('dd.MM.yyyy\nHH:mm:ss').format(DateTime.now());

    if (currentLog == null) {
      await _storage.write(key: _key, value: '$now|$type|$title|$message');
      return;
    }

    final logList = currentLog.split('!!');
    if (logList.length > 50) {
      logList.removeAt(0);

      String newLog = '';
      for (String logMessage in logList) {
        newLog += '!!$logMessage';
      }

      ///!! уже введен в цикле
      await _storage.write(
          key: _key, value: '$now|$type|$title|$message$newLog');
      return;
    }

    await _storage.write(
        key: _key, value: '$now|$type|$title|$message!!$currentLog');
  }

  static Future<void> clearLog() async {
    await _storage.delete(key: _key);
  }

  static Future<List<String>> getLog() async {
    final log = await _storage.read(key: _key);
    return log?.split('!!').toList() ?? [];
  }
}
