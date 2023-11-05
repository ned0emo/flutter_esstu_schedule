import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_update_event.dart';

part 'favorite_update_state.dart';

class FavoriteUpdateBloc
    extends Bloc<FavoriteUpdateEvent, FavoriteUpdateState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteUpdateBloc(FavoriteRepository repository)
      : _favoriteRepository = repository,
        super(FavoriteUpdateInitial()) {
    on<FavoriteUpdateEvent>((event, emit) {});
    on<UpdateSchedule>(_updateSchedule);
  }

  Future<void> _updateSchedule(
      UpdateSchedule event, Emitter<FavoriteUpdateState> emit) async {
    if (event.scheduleModel.link1 == null ||
        state is FavoriteScheduleUpdating) {
      return;
    }

    emit(FavoriteScheduleUpdating());

    try {
      final pagesList = await _favoriteRepository.loadSchedulePages(
        event.scheduleModel.link1!,
        link2: event.scheduleModel.link2,
      );

      //final oldLength = pagesList.length;
      pagesList.removeWhere(
          (element) => !element.contains(event.scheduleModel.name));

      if (pagesList.isEmpty) {
        emit(FavoriteScheduleUpdateError(Logger.warning(
          title: Errors.updateError,
          exception: 'Расписание не найдено по сохраненной ссылке',
        )));
        return;
      }

      //String? message;
      //if (pagesList.length < oldLength) {
      //  message = 'Возможно, расписание обновлено не полностью. '
      //      'Фамилия и инициалы не найдены на одной из сохраненных страниц';
      //}

      final isThereCustomDaysOfWeeks = event.scheduleModel.isZo;
      final numOfLessons = isThereCustomDaysOfWeeks ? 7 : 6;

      ///35 От балды. на неделю больше 28
      ///А вообще теоретически нужно только для преподов
      final numOfDays = isThereCustomDaysOfWeeks ? 35 : 12;

      final scheduleModel = ScheduleModel(
        name: event.scheduleModel.name,
        type: event.scheduleModel.type,
        weeks: [],
        link1: event.scheduleModel.link1,
        link2: event.scheduleModel.link2,
      );

      final oldModelStr = event.scheduleModel.toString();

      for (String page in pagesList) {
        final splittedPage = page
            .substring(page.indexOf(event.scheduleModel.name))
            .replaceAll(' COLOR="#0000ff"', '')
            .split('SIZE=2><P ALIGN="CENTER">')
            .skip(1);

        int dayOfWeekIndex = 0;
        for (String dayOfWeek in splittedPage) {
          String? dayOfWeekDate;
          if (isThereCustomDaysOfWeeks) {
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
              event.scheduleModel.type == ScheduleType.teacher
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

          ///Обяз для преподов
          if (++dayOfWeekIndex >= numOfDays) break;
        }
      }

      final newModelStr = scheduleModel.toString();
      if (oldModelStr != newModelStr) {
        await _favoriteRepository.saveSchedule(event.fileName, newModelStr);

        emit(FavoriteScheduleUpdated(
            scheduleName: event.scheduleModel.name,
            scheduleType: event.scheduleModel.type,
            message: 'Расписание обновлено'));
        return;
      }

      if (event.isAutoUpdate) {
        emit(FavoriteUpdateInitial());
      } else {
        emit(FavoriteUpdateInitial(message: 'Расписание обновлено'));
      }
    } catch (e, stack) {
      emit(FavoriteScheduleUpdateError(Logger.warning(
        title: Errors.updateError,
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
