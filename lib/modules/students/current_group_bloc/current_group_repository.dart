import 'package:enough_convert/enough_convert.dart';
import 'package:http/http.dart' as http;

class CurrentGroupRepository {
  ///Загрузка страницы конкретной группы.
  ///
  /// Шаблон [link] - /{каталог расписания по его типу (маги, баки и т п)}/{номер сслыки}.htm
  ///
  /// Пример: /bakalavriat/13.htm
  ///
  /// portal.esstu.ru уже есть
  Future<String> loadCurrentGroupSchedulePage(String link) async {
    const codec = Windows1251Codec(allowInvalid: false);
    final pageText = await http.readBytes(Uri.https('portal.esstu.ru', link));
    return codec.decode(pageText);
  }
}
