import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/models/lesson_model.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/schedule_time_data.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_schedule_event.dart';

part 'favorite_schedule_state.dart';

class FavoriteScheduleBloc
    extends Bloc<FavoriteScheduleEvent, FavoriteScheduleState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteScheduleBloc(FavoriteRepository repository)
      : _favoriteRepository = repository,
        super(FavoriteScheduleInitial()) {
    on<LoadFavoriteSchedule>(_loadFavoriteSchedule);
    on<ChangeOpenedDay>(_changeOpenedDay);
    on<OpenMainFavSchedule>(_openMainFavSchedule);
  }

  Future<void> _loadFavoriteSchedule(
      LoadFavoriteSchedule event, Emitter<FavoriteScheduleState> emit) async {
    emit(FavoriteScheduleLoading());

    try {
      final scheduleModel =
          await _favoriteRepository.getScheduleModel(event.scheduleFileName);
      if (scheduleModel == null) {
        emit(FavoriteScheduleError(Logger.error(
          title: Errors.scheduleError,
          exception: 'scheduleModel == null',
        )));
        return;
      }

      emit(FavoriteScheduleLoaded(
        scheduleName: scheduleModel.name,
        scheduleList: scheduleModel.scheduleList,
        scheduleType: scheduleModel.scheduleType,
        openedDayIndex: ScheduleTimeData.getCurrentDayOfWeek(),
        currentLesson: ScheduleTimeData.getCurrentLessonIndex(),
        weekNumber: ScheduleTimeData.getCurrentWeekIndex(),
        link1: scheduleModel.link1,
        link2: scheduleModel.link2,
        customDaysOfWeek: scheduleModel.daysOfWeekList,
        isNeedUpdate: event.isNeedUpdate,
        isFromMainPage: event.isFromMainPage,
      ));
    } catch (e, stack) {
      emit(FavoriteScheduleError(Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
    }
  }

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<FavoriteScheduleState> emit) async {
    final currentState = state;
    if (currentState is FavoriteScheduleLoaded) {
      emit(currentState.copyWith(openedDayIndex: event.dayIndex));
    }
  }

  Future<void> _openMainFavSchedule(
      OpenMainFavSchedule event, Emitter<FavoriteScheduleState> emit) async {
    final scheduleName = await _favoriteRepository.getMainFavScheduleName();
    if (scheduleName == null) return;

    add(LoadFavoriteSchedule(scheduleName, isFromMainPage: true));
  }
}
