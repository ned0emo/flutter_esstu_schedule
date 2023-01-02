import 'package:enough_convert/enough_convert.dart';
import 'package:http/http.dart' as http;

class CurrentGroupRepository {
  ///Загрузка страницы конкретной группы.
  ///В link надо передать полную ссылку без http(s) и www
  Future<String> loadCurrentGroupSchedulePage(String link) async {
    const codec = Windows1251Codec(allowInvalid: false);
    final pageText = await http.readBytes(Uri.https('portal.esstu.ru', link));
    return codec.decode(pageText);
  }
}
