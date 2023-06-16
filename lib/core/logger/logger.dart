import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class Logger {
  static String error = 'error';
  static String warning = 'warning';
  static String info = 'info';

  final String _key = 'logService';
  final _storage = const FlutterSecureStorage();

  Future<void> addLog(String type, String title, String message) async {
    final currentLog = await _storage.read(key: _key);
    final now = DateFormat('dd.MM.YYYY').format(DateTime.now());

    if (currentLog == null) {
      await _storage.write(key: _key, value: '$now|$type|$title|$message');
      return;
    }

    final logList = currentLog.split('\n');
    if (logList.length > 30) {
      logList.removeAt(0);

      String newLog = '';
      for (String logMessage in logList) {
        newLog += '\n$logMessage';
      }

      ///Перенос строки уже выполнен в цикле
      await _storage.write(
          key: _key, value: '$now|$type|$title|$message$newLog');
      return;
    }

    await _storage.write(
        key: _key, value: '$now|$type|$title|$message\n$currentLog');
  }

  Future<void> clearLog() async {
    await _storage.delete(key: _key);
  }

  Future<List<String>> getLog() async {
    final log = await _storage.read(key: _key);
    return log?.split('|').toList() ?? [];
  }
}
