import 'package:enough_convert/enough_convert.dart';
import 'package:http/http.dart' as http;

class MainRepository {
  final codec = const Windows1251Codec(allowInvalid: false);

  Future<String> loadPage(String link) async {
    return codec
        .decode(await http.readBytes(Uri.https('portal.esstu.ru', link)));
  }
}