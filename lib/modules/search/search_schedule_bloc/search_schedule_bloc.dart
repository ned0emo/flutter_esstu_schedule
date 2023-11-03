import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/modules/home/main_repository.dart';

part 'search_schedule_event.dart';
part 'search_schedule_state.dart';

class SearchScheduleBloc
    extends Bloc<SearchScheduleEvent, SearchScheduleState> {
  final MainRepository _repository;

  SearchScheduleBloc(MainRepository repository)
      : _repository = repository,
        super(SearchScheduleInitial()) {
    on<SearchScheduleEvent>((event, emit) {});
    on<LoadSearchingSchedule>(_loadSearchingSchedule);
  }

  Future<void> _loadSearchingSchedule(
      LoadSearchingSchedule event, Emitter<SearchScheduleState> emit) async {
    emit(SearchScheduleLoading(appBarName: event.scheduleName));

    final isZo = event.link1.contains('zo');
    final numOfLessons = isZo ? 7 : 6;

    try {
      final pagesList = <String>[
        await _repository.loadPage(event.link1),
        if (event.link2 != null) await _repository.loadPage(event.link2!)
      ];

      //final List<List<Lesson>> scheduleList = [];
      final ScheduleModel scheduleModel = ScheduleModel(
        name: event.scheduleName,
        type: event.scheduleType,
        weeks: [],
        link1: event.link1,
        link2: event.link2,
      );

      for (String page in pagesList) {
        final scheduleBeginning = event.scheduleType == ScheduleType.teacher
            ? page.split(event.scheduleName).elementAt(1)
            : page;

        final splittedPage = event.scheduleType == ScheduleType.teacher
            ? scheduleBeginning
                .substring(0, scheduleBeginning.indexOf('</TABLE>'))
                .replaceAll(' COLOR="#0000ff"', '')
                .split('SIZE=2><P ALIGN="CENTER">')
                .skip(1)
            : scheduleBeginning
                .replaceAll(' COLOR="#0000ff"', '')
                .split('SIZE=2><P ALIGN="CENTER">')
                .skip(1);

        int dayOfWeekIndex = 0;
        for (String dayOfWeek in splittedPage) {
          String? dayOfWeekDate;
          if (isZo) {
            final lastIndex = dayOfWeek.indexOf('</B>');
            dayOfWeekDate = lastIndex > 0
                ? _dateFromZoDayOfWeek(dayOfWeek.substring(0, lastIndex).trim())
                : null;
          }
          final lessons = dayOfWeek.split('"CENTER">').skip(1);

          int lessonIndex = 0;
          for (String lessonSection in lessons) {
            final lesson = lessonSection
                .substring(0, lessonSection.indexOf('</FONT>'))
                .trim();

            final lessonChecker =
                lesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

            if (lessonChecker.isEmpty) {
              if (++lessonIndex >= numOfLessons) break;
              continue;
            }

            scheduleModel.updateWeek(
              dayOfWeekIndex ~/ numOfLessons,
              dayOfWeekIndex % numOfLessons,
              lessonIndex,
              event.scheduleType == ScheduleType.teacher
                  ? LessonBuilder.createTeacherLesson(
                      lessonNumber: lessonIndex + 1,
                      lesson: lesson,
                    )
                  : LessonBuilder.createStudentLesson(
                      lessonNumber: lessonIndex + 1,
                      lesson: lesson,
                    ),
              dayOfWeekDate: dayOfWeekDate,
            );

            if (++lessonIndex >= numOfLessons) break;
          }

          dayOfWeekIndex++;
        }
      }

      emit(SearchScheduleLoaded(
        scheduleModel: scheduleModel,
        appBarName: event.scheduleName,
      ));
    } catch (e, stack) {
      emit(SearchScheduleError(Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
    }
  }

  String? _dateFromZoDayOfWeek(String? dayOfWeek) {
    if (dayOfWeek == null) return null;

    final splittedDayOfWeek = dayOfWeek.split(RegExp(r'\s+'));
    if (splittedDayOfWeek.length < 2) return null;

    final day = splittedDayOfWeek[0].contains(',')
        ? splittedDayOfWeek[0].split(',')[1]
        : splittedDayOfWeek[0];

    final month = splittedDayOfWeek[1];
    if (month.contains('янв') || month.contains('ЯНВ')) {
      return '$day.01';
    }
    if (month.contains('фев') || month.contains('ФЕВ')) {
      return '$day.02';
    }
    if (month.contains('мар') || month.contains('МАР')) {
      return '$day.03';
    }
    if (month.contains('апр') || month.contains('АПР')) {
      return '$day.04';
    }
    if (month.contains('мая') ||
        month.contains('МАЯ') ||
        month.contains('май') ||
        month.contains('МАЙ')) {
      return '$day.05';
    }
    if (month.contains('июн') || month.contains('ИЮН')) {
      return '$day.06';
    }
    if (month.contains('июл') || month.contains('ИЮЛ')) {
      return '$day.07';
    }
    if (month.contains('авг') || month.contains('АВГ')) {
      return '$day.08';
    }
    if (month.contains('сен') || month.contains('СЕН')) {
      return '$day.09';
    }
    if (month.contains('окт') || month.contains('ОКТ')) {
      return '$day.10';
    }
    if (month.contains('ноя') || month.contains('НОЯ')) {
      return '$day.11';
    }
    if (month.contains('дек') || month.contains('ДЕК')) {
      return '$day.12';
    }

    return null;
  }
}
