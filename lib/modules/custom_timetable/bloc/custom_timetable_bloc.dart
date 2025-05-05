import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/models/day_of_week_model.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/models/week_model.dart';
import 'package:schedule/core/static/schedule_time_data.dart';

part 'custom_timetable_event.dart';

part 'custom_timetable_state.dart';

class CustomTimetableBloc
    extends Bloc<CustomTimetableEvent, CustomTimetableState> {
  CustomTimetableBloc() : super(CustomTimetableDataState()) {
    on<AddWeek>((event, emit) {
      if (state is CustomTimeTableBusyState) return;
      emit(_busy);

      state.scheduleModel.weeks.add(WeekModel(
          weekNumber: state.scheduleModel.numOfWeeks + 1, daysOfWeek: []));
      emit(_ready);
    });
    on<RemoveWeek>((event, emit) {
      if (state is CustomTimeTableBusyState) return;
      emit(_busy);

      if (event.weekIndex < state.scheduleModel.numOfWeeks) {
        state.scheduleModel.weeks.removeAt(event.weekIndex);
      }
      emit(_ready);
    });
    on<AddDayOfWeek>((event, emit) {
      if (state is CustomTimeTableBusyState) return;
      emit(_busy);

      if (event.dayOfWeekIndex > 6) {
        emit(_error("Неделя не может иметь больше 7 дней"));
        return;
      }
      if (event.week.daysOfWeek
          .any((dow) => dow.dayOfWeekIndex == event.dayOfWeekIndex)) {
        emit(_error("Такой день недели уже был добавлен"));
        return;
      }

      event.week.daysOfWeek.add(DayOfWeekModel(
        dayOfWeekNumber: event.dayOfWeekIndex + 1,
        dayOfWeekName: ScheduleTimeData.daysOfWeekShort[event.dayOfWeekIndex],
        lessons: [],
        dayOfWeekDate: event.dayOfWeekDate,
      ));
      emit(_ready);
    });
    on<RemoveDayOfWeek>((event, emit) {
      if (state is CustomTimeTableBusyState) return;
      emit(_busy);

      if (event.dayOfWeekIndex < event.week.weekLength) {
        event.week.daysOfWeek.removeAt(event.dayOfWeekIndex);
      }
      emit(_ready);
    });
    on<AddLesson>((event, emit) {
      if (state is CustomTimeTableBusyState) return;
      emit(_busy);

      if (event.lessonIndex > 6) {
        emit(_error("Количество занятий не может превышать 7"));
        return;
      }

      if (event.dayOfWeek.lessons
          .any((l) => l.lessonIndex == event.lessonIndex)) {
        emit(_error("Занятие на данное время уже добавлено"));
        return;
      }

      event.dayOfWeek.lessons.add(Lesson(
          lessonNumber: event.lessonIndex + 1, lessonData: [], fullLesson: ''));
      emit(_ready);
    });
  }

  CustomTimeTableBusyState get _busy =>
      CustomTimeTableBusyState(state.scheduleModel);

  CustomTimetableDataState get _ready =>
      CustomTimetableDataState.ready(state.scheduleModel);

  CustomTimetableErrorState _error(String message) =>
      CustomTimetableErrorState(state.scheduleModel, message);
}
