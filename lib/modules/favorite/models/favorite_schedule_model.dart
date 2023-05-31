import 'dart:convert';

///
/// [name] - имя файла (группа/препод/аудитория)
///
/// [link1] - основная ссылка. для преподов их может быть две. nullable потому
/// что расписание аудиторий не имеет возможности обновиться
///
/// [link2] - вторая ссылка для преподов
///
/// [scheduleList] - основной лист с расписанием, где 7/12/14/21/28 листов со
/// списком пар
///
/// [daysOfWeekList] - лист дней недели для заочников
///
class FavoriteScheduleModel {
  final String name;
  final String scheduleType;
  final List<List<String>> scheduleList;
  final String? link1;
  final String? link2;
  final List<String>? daysOfWeekList;

  FavoriteScheduleModel({
    required this.name,
    required this.scheduleType,
    required this.scheduleList,
    this.link1,
    this.link2,
    this.daysOfWeekList,
  });

  static fromJson(Map<String, dynamic> json) => FavoriteScheduleModel(
        name: json['name'],
        scheduleType: json['scheduleType'],
        scheduleList: _scheduleListConvert(json['scheduleList']),
        link1: json['link1'],
        link2: json['link2'],
        daysOfWeekList: _daysOfWeekListConvert(json['daysOfWeekList']),
      );

  static fromString(String str) => fromJson(jsonDecode(str));

  static List<List<String>> _scheduleListConvert(List<dynamic> list){
    List<List<String>> newList = [];
    for(dynamic it in list){
      newList.add(List<String>.from(it));
    }

    return newList;
  }

  static List<String>? _daysOfWeekListConvert(List<dynamic>? list){
    return list != null ? List<String>.from(list) : null;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'scheduleType': scheduleType,
        'scheduleList': scheduleList,
        'link1': link1,
        'link2': link2,
        'daysOfWeekList': daysOfWeekList,
      };

  @override
  toString() => jsonEncode(toJson());
}
