import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';
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
  }

  Future<void> _loadFavoriteSchedule(
      LoadFavoriteSchedule event, Emitter<FavoriteScheduleState> emit) async {
    emit(FavoriteScheduleLoading());

    try {
      final scheduleModel =
          await _favoriteRepository.getScheduleModel(event.scheduleName);
      if (scheduleModel == null) {
        emit(FavoriteScheduleError(
            'Ошибка загрузки расписания\nscheduleModel == null'));
        return;
      }

      int currentLesson = -1;
      final currentTime = Jiffy().dateTime.minute + Jiffy().dateTime.hour * 60;
      if (currentTime >= 540 && currentTime <= 635) {
        currentLesson = 0;
      } else if (currentTime >= 645 && currentTime <= 740) {
        currentLesson = 1;
      } else if (currentTime >= 780 && currentTime <= 875) {
        currentLesson = 2;
      } else if (currentTime >= 885 && currentTime <= 980) {
        currentLesson = 3;
      } else if (currentTime >= 985 && currentTime <= 1080) {
        currentLesson = 4;
      } else if (currentTime >= 1085 && currentTime <= 1180) {
        currentLesson = 5;
      }

      emit(FavoriteScheduleLoaded(
        currentScheduleName: scheduleModel.name,
        scheduleList: scheduleModel.scheduleList,
        openedDayIndex: Jiffy().dateTime.weekday - 1,
        currentLesson: currentLesson,
        weekNumber: (Jiffy().week + 1) % 2,
        customDaysOfWeek: scheduleModel.daysOfWeekList,
      ));
    } on TypeError catch (e) {
      emit(FavoriteScheduleError(
          '${e.runtimeType.toString()}\n${e.stackTrace}'));
    } catch (e) {
      emit(FavoriteScheduleError(e.runtimeType.toString()));
    }
  }

  Future<void> _changeOpenedDay(
      ChangeOpenedDay event, Emitter<FavoriteScheduleState> emit) async {
    final currentState = state;
    if (currentState is FavoriteScheduleLoaded) {
      emit(currentState.copyWith(openedDayIndex: event.dayIndex));
    }
  }
}
