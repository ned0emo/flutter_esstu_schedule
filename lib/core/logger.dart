import 'dart:io';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// | - Разделитель данных сообщения
///
/// !! - Разделитель сообщений
class Logger {
  //static const String error = 'error';
  //static const String warning = 'warning';
  //static const String info = 'info';

  static const String _key = 'logService';

  static String _exceptionToString(dynamic e) {
    if (e is SocketException) {
      return 'Ошибка подключения'
          '\nАдрес: ${e.address?.address}'
          '\nСообщение: ${e.message}';
    }

    if (e is RangeError) {
      return 'Ошибка обработки массива'
          '\nИмя аргумента: ${e.name}'
          '\nМинимально допустимое значение: ${e.start}'
          '\nМаксимально допустимое значение: ${e.end}'
          '\nТекущее значение: ${e.invalidValue}'
          '\nСообщение: ${e.message}'
          '\nТрассировка: ${e.stackTrace}';
    }

    if (e is TypeError) {
      return 'Ошибка преобразования файла'
          '\n${e.stackTrace}';
    }

    if (e is String) {
      return e;
    }

    if (e == null) {
      return 'null';
    }

    return 'Неизвестная ошибка: ${e.runtimeType}';
  }

  static String error(
      {required String title, required dynamic exception, StackTrace? stack}) {
    final message = _exceptionToString(exception);
    _addLog('error', title, '$message\n\n$stack');

    return '$title\n$message';
  }

  static String warning(
      {required String title, required dynamic exception, StackTrace? stack}) {
    final message = _exceptionToString(exception);
    _addLog('warning', title, '$message\n\n$stack');

    return '$title\n$message';
  }

  static String info({required String title, required dynamic exception}) {
    final message = _exceptionToString(exception);
    _addLog('info', title, message);

    return '$title\n$message';
  }

  static Future<void> _addLog(String type, String title, String message) async {
    final storage = await SharedPreferences.getInstance();
    //print(type);
    //print(title);
    //print(message);

    //String? currentLog;
    //try{
    //  currentLog = await _storage.read(key: _key);
    //}
    //catch(e){
    //  return;
    //}

    final currentLog = storage.getString(_key);

    final now = DateFormat('dd.MM.yyyy\nHH:mm:ss').format(DateTime.now());

    if (currentLog == null) {
      await storage.setString(_key, '$now|$type|$title|$message');
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
      await storage.setString(_key, '$now|$type|$title|$message$newLog');
      return;
    }

    await storage.setString(_key, '$now|$type|$title|$message!!$currentLog');

    return;
  }

  static Future<void> clearLog() async {
    final storage = await SharedPreferences.getInstance();
    await storage.remove(_key);
  }

  static Future<List<String>> getLog() async {
    final storage = await SharedPreferences.getInstance();
    final log = storage.getString(_key);
    return log?.split('!!').toList() ?? [];
  }
}
