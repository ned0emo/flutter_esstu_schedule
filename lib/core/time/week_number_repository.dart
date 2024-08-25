import 'package:http/http.dart' as http;
import 'package:schedule/core/logger/errors.dart';
import 'package:schedule/core/logger/logger.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/core/time/current_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeekNumberRepository {
  Future<void> setWeekShifting() async {
    try {
      //await Future.delayed(Duration(milliseconds: 2000));
      final result = await http.read(Uri.https('esstu.ru', 'index.htm'));

      final weekTag =
          RegExp(r'<span class="header-date">.*</span>').firstMatch(result)?[0];

      if (weekTag == null) {
        Logger.error(
            title: Errors.weekIndex,
            exception: 'Номер недели не найден на странице расписания');
        throw Exception();
      }

      final weekIndex = weekTag.contains('II') ? 1 : 0;
      if (weekIndex != CurrentTime.weekIndex) {
        final currentShifting = await _loadShifting();

        if (currentShifting) {
          CurrentTime.weekShifting = 0;
          await _saveShifting(false);
        } else {
          CurrentTime.weekShifting = 1;
          await _saveShifting(true);
        }
      }
    } catch (e) {
      Logger.error(title: Errors.weekIndex, exception: e);
      rethrow;
    }
  }

  Future<void> _saveShifting(bool shifting) async {
    var storage = await SharedPreferences.getInstance();

    await storage.setString(
        SettingsTypes.weekIndexShifting, shifting.toString());
  }

  Future<bool> _loadShifting() async {
    var storage = await SharedPreferences.getInstance();

    return storage.getString(SettingsTypes.weekIndexShifting) == 'true';
  }
}
