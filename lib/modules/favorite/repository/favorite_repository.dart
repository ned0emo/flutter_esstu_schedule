import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:schedule/modules/favorite/models/favorite_schedule_model.dart';

///
/// Название ключа расписания для сохранения должно выглядеть:
///
/// "<тип расписания>|<название расписания>"
///
/// Название ключа для настроек должно содержать слово service
///
class FavoriteRepository {
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
}
