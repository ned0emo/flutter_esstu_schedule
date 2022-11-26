import 'package:http/http.dart' as http;

class StudentsRepository {
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

    final bakResponse =
        await http.get(Uri.https('portal.esstu.ru/bakalavriat/raspisan.htm'));
    if (bakResponse.statusCode == 200) {
      pagesList[0] = bakResponse.body;
    }

    final magResponse =
        await http.get(Uri.https('portal.esstu.ru/spezialitet/raspisan.htm'));
    if (magResponse.statusCode == 200) {
      pagesList[1] = magResponse.body;
    }

    final zo1Response =
        await http.get(Uri.https('portal.esstu.ru/zo1/raspisan.htm'));
    if (zo1Response.statusCode == 200) {
      pagesList[2] = zo1Response.body;
    }

    final zo2Response =
        await http.get(Uri.https('portal.esstu.ru/zo2/raspisan.htm'));
    if (zo2Response.statusCode == 200) {
      pagesList[3] = zo2Response.body;
    }

    return pagesList;
  }

  ///Загрузка страницы конкретной группы.
  ///В link надо передать полную ссылку без http(s) и www
  ///
  /// Если возврат пустой строки, значит ошибка загрузки
  Future<String> loadSchedulePage(String link) async {
    final response = await http.get(Uri.https(link));
    if(response.statusCode == 200){
      return response.body;
    }
    return '';
  }
}
