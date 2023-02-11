import 'package:enough_convert/enough_convert.dart';
import 'package:http/http.dart' as http;

class AllGroupsRepository {
  /// Загрузка сайтов со списком групп и добавление всех загруженных
  /// страниц в один лист.
  ///
  /// Порядок добавления:
  /// 0 - бакалавры;
  /// 1 - маги и колледж;
  /// 2 - первая заочка;
  /// 3 - вторая заочка.
  ///
  /// Список всегда непустой. По умолчанию содержит 4 пустые строки,
  /// по которым можно определить успешность загрузки страницы
  Future<List<String>> loadGroupsPages() async {
    final List<String> pagesList = ['', '', '', ''];
    const codec = Windows1251Codec(allowInvalid: false);

    final bakResponse = await http
        .readBytes(Uri.https('portal.esstu.ru', '/bakalavriat/raspisan.htm'));
    pagesList[0] = codec.decode(bakResponse);

    final magResponse = await http
        .readBytes(Uri.https('portal.esstu.ru', '/spezialitet/raspisan.htm'));
    pagesList[1] = codec.decode(magResponse);

    final zo1Response =
        await http.readBytes(Uri.https('portal.esstu.ru', '/zo1/raspisan.htm'));
    pagesList[2] = codec.decode(zo1Response);

    final zo2Response =
        await http.readBytes(Uri.https('portal.esstu.ru', '/zo2/raspisan.htm'));
    pagesList[3] = codec.decode(zo2Response);

    return pagesList;
  }
}
