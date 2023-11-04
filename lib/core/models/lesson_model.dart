import 'dart:convert';

class Lesson {
  ///Для заполнения lessonData
  static const teachers = 'teachers';
  static const classrooms = 'classrooms';
  static const title = 'title';
  static const type = 'type';

  final int lessonNumber;
  final String fullLesson;
  final List<Map<String, String>>? lessonData;

  const Lesson({
    required this.lessonNumber,
    required this.lessonData,
    required this.fullLesson,
  });

  @override
  toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'lessonNumber': lessonNumber,
        'fullLesson': fullLesson,
        'lessonData': lessonData,
      };

  static Lesson fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> lessonDataFromJson(List<dynamic> list) {
      final List<Map<String, String>> newList = [];
      for (Map<dynamic, dynamic> lessonData in list) {
        newList.add(
            lessonData.map((key, value) => MapEntry(key, value.toString())));
      }
      return newList;
    }

    return Lesson(
      lessonNumber: json['lessonNumber'],
      fullLesson: json['fullLesson'],
      lessonData: lessonDataFromJson(json['lessonData']),
    );
  }

  bool get isEmpty => fullLesson.isEmpty;

  int get lessonIndex => lessonNumber - 1;
}
