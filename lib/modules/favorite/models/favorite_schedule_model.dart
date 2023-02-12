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
  final String? name;
  final String? link1;
  final String? link2;
  final List<List<String>>? scheduleList;
  final List<String>? daysOfWeekList;

  FavoriteScheduleModel({
    required this.name,
    this.link1,
    this.link2,
    required this.scheduleList,
    this.daysOfWeekList,
  });

  static fromJson(Map<String, dynamic> json) => FavoriteScheduleModel(
        name: json['name'],
        link1: json['link1'],
        link2: json['link2'],
        scheduleList: json['scheduleList'],
      );

  static fromString(String str) => fromJson(jsonDecode(str));

  Map<String, dynamic> toJson() => {
        'name': name,
        'link1': link1,
        'link2': link2,
        'scheduleList': scheduleList
      };

  @override
  toString() => jsonEncode(toJson());
}
