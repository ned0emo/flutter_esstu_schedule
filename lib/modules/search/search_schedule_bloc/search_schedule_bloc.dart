import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/schedule_time_data.dart';
import 'package:schedule/core/schedule_type.dart';
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

      final List<List<String>> scheduleList = [];
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
            scheduleList.add(List.generate(numOfLessons, (index) => ''));
          }

          int j = 0;
          for (String dayOfWeekSection in daysOfWeek) {
            final lesson = dayOfWeekSection
                .substring(0, dayOfWeekSection.indexOf('<'))
                .trim();
            if (lesson.length > scheduleList[i][j].length) {
              scheduleList[i][j] = lesson;
            }

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
        currentLesson: ScheduleTimeData.getCurrentLessonNumber(),
        weekNumber: ScheduleTimeData.getCurrentWeekNumber(),
        link1: event.link1,
        link2: event.link2,
        customDaysOfWeek: customDaysOfWeek,
      ));
    } on SocketException catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка загрузки расписания',
        'Отсутствие интернета или недоступность сайта:'
            '\n${e.address}\n${e.message}',
      );

      emit(SearchScheduleError(
          'Ошибка загрузки расписания:\n${e.address}\n${e.message}'));
    } on RangeError catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка загрузки расписания',
        'Имя аргумента: ${e.name}'
            '\nМинимально допустимое значение: ${e.start}'
            '\nМаксимально допустимое значение: ${e.end}'
            '\nТекущее значение: ${e.invalidValue}'
            '\n${e.message}'
            '\n${e.stackTrace}',
      );

      emit(SearchScheduleError(
        'Ошибка загрузки расписания:\nИмя аргумента: ${e.name}'
        '\nМинимально допустимое значение: ${e.start}'
        '\nМаксимально допустимое значение: ${e.end}'
        '\nТекущее значение: ${e.invalidValue}'
        '\n${e.message}',
      ));
    } catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка загрузки расписания',
        'Неизвестная ошибка. Тип: ${e.runtimeType}',
      );

      emit(SearchScheduleError('Ошибка загрузки расписания: ${e.runtimeType}'));
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
