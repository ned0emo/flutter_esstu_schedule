import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/modules/home/main_repository.dart';

part 'current_group_event.dart';

part 'current_group_state.dart';

class CurrentGroupBloc extends Bloc<CurrentGroupEvent, CurrentGroupState> {
  final MainRepository _repository;

  CurrentGroupBloc(MainRepository repository)
      : _repository = repository,
        super(CurrentGroupInitial()) {
    on<LoadGroup>(_loadGroup);
  }

  Future<void> _loadGroup(
      LoadGroup event, Emitter<CurrentGroupState> emit) async {
    emit(CurrentGroupLoading());

    try {
      final page = await _repository.loadPage(event.link);

      String? groupNameOnPage = RegExp(r'#ff00ff">.*</P').firstMatch(page)?[0];
      if (groupNameOnPage != null) {
        groupNameOnPage = groupNameOnPage
            .replaceAll('#ff00ff">', '')
            .replaceAll('</P', '')
            .trim();
      }

      final message = groupNameOnPage == event.scheduleName
          ? null
          : 'Загруженное расписание может не соответствовать выбранной группе.\n\n'
              'Выбранная группа: ${event.scheduleName}\n'
              'Загруженная группа: $groupNameOnPage';

      final currentScheduleModel = ScheduleModel(
        name: event.scheduleName,
        type: ScheduleType.student,
        weeks: [],
        link1: event.link,
      );

      final isThereCustomDaysOfWeeks = event.isZo;
      final numOfLessons = event.isZo ? 7 : 6;

      final scheduleSection = page
          .substring(page.indexOf('ff00ff">'))
          .replaceAll(' COLOR="#0000ff"', '');

      final daysOfWeekFromPage =
          scheduleSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

      int dayOfWeekIndex = 0;
      for (String dayOfWeek in daysOfWeekFromPage) {
        String? dayOfWeekDate;
        if (isThereCustomDaysOfWeeks) {
          final lastIndex = dayOfWeek.indexOf('</B>');
          dayOfWeekDate = lastIndex > 0
              ? _dateFromZoDayOfWeek(dayOfWeek.substring(0, lastIndex).trim())
              : null;
        }

        final lessons = dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

        int lessonIndex = 0;
        for (String lessonSection in lessons) {
          final lesson = lessonSection
              .substring(0, lessonSection.indexOf('</FONT>'))
              .trim();

          final lessonChecker = lesson.replaceAll(RegExp(r'[^0-9а-яА-Я]'), '');

          if (lessonChecker.isEmpty) {
            lessonIndex++;
            continue;
          }

          currentScheduleModel.updateWeek(
            dayOfWeekIndex ~/ numOfLessons,
            dayOfWeekIndex % numOfLessons,
            lessonIndex,
            LessonBuilder.createStudentLesson(
              lessonNumber: lessonIndex + 1,
              lesson: lesson,
            ),
            dayOfWeekDate: dayOfWeekDate,
          );

          if (++lessonIndex >= numOfLessons) break;
        }

        dayOfWeekIndex++;
      }

      emit(CurrentGroupLoaded(
        name: event.scheduleName,
        scheduleModel: currentScheduleModel,
        message: message,
      ));
    } catch (e, stack) {
      emit(CurrentGroupError(Logger.error(
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
