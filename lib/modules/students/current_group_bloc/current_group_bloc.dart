import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/lesson_builder.dart';
import 'package:schedule/core/static/schedule_time_data.dart';
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

      List<List<Lesson>> scheduleList = [];
      List<String>? customDaysOfWeek = event.isZo ? [] : null;
      final numOfLessons = event.isZo ? 7 : 6;

      final scheduleSection = page
          .substring(page.indexOf('ff00ff">'))
          .replaceAll(' COLOR="#0000ff"', '');

      final daysOfWeekFromPage =
          scheduleSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

      int j = 0;
      for (String dayOfWeek in daysOfWeekFromPage) {
        scheduleList.add(List.generate(
            numOfLessons, (index) => Lesson(lessonNumber: index + 1)));
        if (customDaysOfWeek != null) {
          try {
            customDaysOfWeek
                .add(dayOfWeek.substring(0, dayOfWeek.indexOf('</B>')).trim());
          } catch (e, stack) {
            Logger.warning(
              title: Errors.pageParsingError,
              exception: e,
              stack: stack,
            );

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

          //scheduleList[j][i] = LessonBuilder.createStudentLesson(i + 1, lesson);//.updateLesson(lesson);

          if (++i >= numOfLessons) break;
        }

        j++;
      }

      emit(CurrentGroupLoaded(
        name: event.scheduleName,
        scheduleList: scheduleList,
        link: event.link,
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeekIndex(),
        currentLesson: ScheduleTimeData.getCurrentLessonIndex(),
        weekNumber: ScheduleTimeData.getCurrentWeekIndex(),
        daysOfWeekList: customDaysOfWeek,
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

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<CurrentGroupState> emit) async {
    final currentState = state;
    if (currentState is CurrentGroupLoaded) {
      emit(currentState.copyWith(openedDayIndex: event.numOfDay));
    }
  }
}
