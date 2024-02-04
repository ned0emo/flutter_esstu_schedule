import 'dart:io';

import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// | - Разделитель данных сообщения
///
/// !! - Разделитель сообщений
class Logger {
  final String _key = 'logService';
  final String _divider = '!!';

  String _exceptionToString(dynamic e) {
    if (e is SocketException) {
      return 'Ошибка подключения'
          '\nАдрес: ${e.address?.address}'
          '\nСообщение: ${e.message}';
    }

    if (e is ClientException) {
      return 'Ошибка подключения'
          '\nАдрес: ${e.uri?.path}'
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

  String error(
      {required String title, required dynamic exception, StackTrace? stack}) {
    final message = _exceptionToString(exception);
    _addLog('error', title, '$message\n\n$stack');

    return '$title\n$message';
  }

  String warning(
      {required String title, required dynamic exception, StackTrace? stack}) {
    final message = _exceptionToString(exception);
    _addLog('warning', title, '$message\n\n$stack');

    return '$title\n$message';
  }

  String info({required String title, required dynamic exception}) {
    final message = _exceptionToString(exception);
    _addLog('info', title, message);

    return '$title\n$message';
  }

  Future<void> _addLog(String type, String title, String message) async {
    final storage = await SharedPreferences.getInstance();
    final currentLog = storage.getString(_key);

    final now = DateFormat('dd.MM.yyyy\nHH:mm:ss').format(DateTime.now());

    if (currentLog == null) {
      await storage.setString(_key, '$now|$type|$title|$message');
      return;
    }

    final logList = currentLog.split(_divider);
    if (logList.length > 50) {
      logList.removeAt(0);

      String newLog = '';
      for (String logMessage in logList) {
        newLog += '!!$logMessage';
      }

      ///Разделитель уже введен в цикле
      await storage.setString(_key, '$now|$type|$title|$message$newLog');
      return;
    }

    await storage.setString(_key, '$now|$type|$title|$message!!$currentLog');

    return;
  }

  Future<void> clearLog() async {
    final storage = await SharedPreferences.getInstance();
    await storage.remove(_key);
  }

  Future<List<String>> getLog() async {
    final storage = await SharedPreferences.getInstance();
    final log = storage.getString(_key);
    return log?.split(_divider).toList() ?? [];
  }
}
