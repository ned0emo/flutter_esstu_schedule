import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_time_data.dart';
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
    on<ChangeOpenedDay>(_changeOpenedDay);
  }

  Future<void> _loadSearchingSchedule(
      LoadSearchingSchedule event, Emitter<SearchScheduleState> emit) async {
    emit(SearchScheduleLoading());

    final isZo = event.link1.contains('zo');
    final numOfLessons = isZo ? 7 : 6;

    try {
      final pagesList = <String>[
        await _repository.loadPage(event.link1),
        if (event.link2 != null) await _repository.loadPage(event.link2!)
      ];

      final List<List<Lesson>> scheduleList = [];
      List<String>? customDaysOfWeek;

      bool isScheduleNeedCreate = true;
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

        int i = 0;
        for (String weekSection in splittedPage) {
          if (isZo) {
            customDaysOfWeek ??= [];
            customDaysOfWeek
                .add(weekSection.substring(0, weekSection.indexOf('<')).trim());
          }

          final daysOfWeek = weekSection.split('"CENTER">').skip(1);
          if (isScheduleNeedCreate) {
            scheduleList.add(List.generate(numOfLessons, (index) => Lesson(lessonNumber: index + 1)));
          }

          int j = 0;
          for (String dayOfWeekSection in daysOfWeek) {
            final lesson = dayOfWeekSection
                .substring(0, dayOfWeekSection.indexOf('<'))
                .trim();

            scheduleList[i][j] = LessonBuilder.createLessonIfTitleLonger(scheduleList[i][j], lesson);//.updateLesson(lesson);

            j++;
            if (j >= numOfLessons) {
              break;
            }
          }

          i++;
        }

        isScheduleNeedCreate = false;
      }

      emit(SearchScheduleLoaded(
        scheduleName: event.scheduleName,
        scheduleList: scheduleList,
        scheduleType: event.scheduleType,
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
        currentLesson: ScheduleTimeData.getCurrentLessonIndex(),
        weekNumber: ScheduleTimeData.getCurrentWeekIndex(),
        link1: event.link1,
        link2: event.link2,
        customDaysOfWeek: customDaysOfWeek,
      ));
    } catch (e, stack) {
      emit(SearchScheduleError(Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
    }
  }

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<SearchScheduleState> emit) async {
    final currentState = state;
    if (currentState is SearchScheduleLoaded) {
      emit(currentState.copyWith(openedDayIndex: event.numOfDay));
    }
  }
}
