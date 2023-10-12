import 'dart:convert';

import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final int lessonNumber;

  final String? _fullLesson;
  final String? _title;
  final String? _type;

  final List<String>? _teachers;
  final List<String>? _groups;
  final List<String>? _classrooms;

  const Lesson(
      {required this.lessonNumber,
      String? fullLesson,
      String? title,
      String? type,
      List<String>? teachers,
      List<String>? groups,
      List<String>? classrooms})
      : _fullLesson = fullLesson,
        _title = title,
        _type = type,
        _teachers = teachers,
        _groups = groups,
        _classrooms = classrooms;

  @override
  toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'lessonNumber': lessonNumber,
        'fullLesson': _fullLesson,
        'title': _title,
        'type': _type,
        'teachers': _teachers,
        'groups': _groups,
        'classrooms': _classrooms,
      };

  static Lesson fromJson(Map<String, dynamic> json) => Lesson(
        lessonNumber: json['lessonNumber'],
        fullLesson: json['fullLesson'],
        title: json['title'],
        type: json['type'],
        teachers: List<String>.from(json['teachers'] ?? []),
        groups: List<String>.from(json['groups'] ?? []),
        classrooms: List<String>.from(json['classrooms'] ?? []),
      );

  bool get isEmpty => _fullLesson?.isEmpty ?? true;

  String get fullLesson => _fullLesson ?? '';

  String get title => _title ?? _fullLesson ?? '';

  String get type => _type ?? '';

  List<String> get teachers => _teachers ?? [];

  List<String> get groups => _groups ?? [];

  List<String> get classrooms => _classrooms ?? [];

  @override
  List<Object?> get props => [_fullLesson, _title];
}
