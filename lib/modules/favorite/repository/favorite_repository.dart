import 'package:enough_convert/enough_convert.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:schedule/modules/favorite/models/favorite_schedule_model.dart';
import 'package:http/http.dart' as http;

///
/// Название ключа расписания для сохранения должно выглядеть:
///
/// "<тип расписания>|<название расписания>"
///
/// Название ключа для настроек должно содержать слово service
///
class FavoriteRepository {
  final _codec = const Windows1251Codec(allowInvalid: false);
  final _storage = const FlutterSecureStorage();

  Future<List<String>> getFavoriteList() async {
    final list = await _storage.readAll();

    list.removeWhere((key, value) => key.contains('service'));

    return list.keys.toList();
  }

  Future<FavoriteScheduleModel?> getScheduleModel(String key) async {
    final scheduleString = await _storage.read(key: key);
    if (scheduleString == null) {
      return null;
    }

    return FavoriteScheduleModel.fromString(scheduleString);
  }

  Future<void> saveSchedule(String key, String schedule) async {
    _storage.write(key: key, value: schedule);
  }

  Future<void> deleteSchedule(String key) async {
    await _storage.delete(key: key);
  }

  Future<bool> checkSchedule(String key) async =>
      (await _storage.readAll()).keys.contains(key);

  Future<void> clearSchedule() async {
    final list = await getFavoriteList();
    for (String key in list) {
      await _storage.delete(key: key);
    }
  }

  Future<List<String>> loadSchedulePages(String link1, {String? link2}) async {
    final pageText1 = await http.readBytes(Uri.https('portal.esstu.ru', link1));
    if (link2 == null) {
      return [_codec.decode(pageText1)];
    }

    final pageText2 = await http.readBytes(Uri.https('portal.esstu.ru', link2));
    return [_codec.decode(pageText1), _codec.decode(pageText2)];
  }
}
