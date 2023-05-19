import 'package:enough_convert/enough_convert.dart';
import 'package:http/http.dart' as http;

class TeachersRepository{
  Future<List<String>> loadFacultiesPage(String link1, String link2) async{
    const codec = Windows1251Codec(allowInvalid: false);

    final pageText1 = await http.readBytes(Uri.https('portal.esstu.ru', link1));
    final pageText2 = await http.readBytes(Uri.https('portal.esstu.ru', link2));

    return [codec.decode(pageText1), codec.decode(pageText2)];
  }
}