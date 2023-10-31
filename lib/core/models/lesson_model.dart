import 'dart:convert';

import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  ///Для заполнения lessonData
  static const teachers = 'teachers';
  static const classrooms = 'classrooms';
  static const title = 'title';
  static const type = 'type';

  final int lessonNumber;

  final String? _fullLesson;
  final String? _title;
  final String? _type;

  final List<String>? _teachers;
  final List<String>? _classrooms;

  final List<Map<String, String>>? lessonData;

  const Lesson({
    required this.lessonNumber,
    this.lessonData,
    String? fullLesson,
    String? title,
    String? type,
    List<String>? teachers,
    List<String>? groups,
    List<String>? classrooms,
  })  : _fullLesson = fullLesson,
        _title = title,
        _type = type,
        _teachers = teachers,
        _classrooms = classrooms;

  @override
  toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'lessonNumber': lessonNumber,
        'fullLesson': _fullLesson,
        'title': _title,
        'type': _type,
        'teachers': _teachers,
        'classrooms': _classrooms,
      };

  static Lesson fromJson(Map<String, dynamic> json) => Lesson(
        lessonNumber: json['lessonNumber'],
        fullLesson: json['fullLesson'],
        title: json['title'],
        type: json['type'],
        teachers: List<String>.from(json['teachers'] ?? []),
        classrooms: List<String>.from(json['classrooms'] ?? []),
      );

  bool get isEmpty => _fullLesson?.isEmpty ?? true;

  String get fullLesson => _fullLesson ?? '';

  String get titleOld => _title ?? _fullLesson ?? '';

  String get typeOld => _type ?? '';

  List<String> get teachersList => _teachers ?? [];

  List<String> get classroomsList => _classrooms ?? [];

  @override
  List<Object?> get props => [_fullLesson, _title];

  int get lessonIndex => lessonNumber - 1;
}
