import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/schedule_time_data.dart';
import 'package:schedule/modules/home/main_repository.dart';

part 'current_group_event.dart';

part 'current_group_state.dart';

class CurrentGroupBloc extends Bloc<CurrentGroupEvent, CurrentGroupState> {
  final MainRepository _repository;

  CurrentGroupBloc(MainRepository repository)
      : _repository = repository,
        super(CurrentGroupInitial()) {
    on<LoadGroup>(_loadGroup);
    on<ChangeOpenedDay>(_changeOpenedDay);
  }

  Future<void> _loadGroup(
      LoadGroup event, Emitter<CurrentGroupState> emit) async {
    emit(CurrentGroupLoading());

    try {
      final page = await _repository.loadPage(event.link);

      List<List<String>> scheduleList = [];
      List<String>? customDaysOfWeek = event.isZo ? [] : null;
      final numOfLessons = event.isZo ? 7 : 6;

      final scheduleSection = page
          .substring(page.indexOf('ff00ff">'))
          .replaceAll(' COLOR="#0000ff"', '');

      final daysOfWeekFromPage =
          scheduleSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

      int j = 0;
      for (String dayOfWeek in daysOfWeekFromPage) {
        scheduleList.add(List.generate(numOfLessons, (index) => ''));
        if (customDaysOfWeek != null) {
          try {
            customDaysOfWeek
                .add(dayOfWeek.substring(0, dayOfWeek.indexOf('</B>')).trim());
          } catch (e) {
            print(e);
            customDaysOfWeek
                .add(ScheduleTimeData.daysOfWeek[customDaysOfWeek.length % 7]);
          }
        }

        final lessons = dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

        int i = 0;
        for (String lessonSection in lessons) {
          final lesson = lessonSection
              .substring(0, lessonSection.indexOf('</FONT>'))
              .trim();

          if (scheduleList[j][i].length < lesson.length) {
            scheduleList[j][i] = lesson;
          }
          i++;
          if (i >= numOfLessons) {
            break;
          }
        }

        j++;
      }

      emit(CurrentGroupLoaded(
        name: event.scheduleName,
        scheduleList: scheduleList,
        link: event.link,
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
        currentLesson: ScheduleTimeData.getCurrentLessonNumber(),
        weekNumber: ScheduleTimeData.getCurrentWeekNumber(),
        daysOfWeekList: customDaysOfWeek,
      ));
    } on RangeError catch (e) {
      emit(CurrentGroupError(
          'Ошибка обработки страницы расписания:'
              '\nИмя аргумента: ${e.name}'
              '\nМинимально допустимое значение: ${e.start}'
              '\nМаксимально допустимое значение: ${e.end}'
              '\nТекущее значение: ${e.invalidValue}'
              '\n${e.message}'));
    } on SocketException catch (e) {
      emit(CurrentGroupError(
          'Ошибка обработки страницы расписания:\n${e.message}'
              '\nВозможно, проблемы с интернетом или с доступом к сайту'));
    } catch (e) {
      emit(CurrentGroupError('Ошибка загрузки расписания:\n${e.runtimeType}'));
    }
  }

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<CurrentGroupState> emit) async {
    final currentState = state;
    if (currentState is CurrentGroupLoaded) {
      emit(currentState.copyWith(openedDayIndex: event.numOfDay));
    }
  }
}
