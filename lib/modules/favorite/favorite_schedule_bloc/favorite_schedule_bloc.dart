import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/logger/logger.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/logger/errors.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_schedule_event.dart';

part 'favorite_schedule_state.dart';

class FavoriteScheduleBloc
    extends Bloc<FavoriteScheduleEvent, FavoriteScheduleState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteScheduleBloc(this._favoriteRepository)
      : super(FavoriteScheduleInitial()) {
    on<ResetSchedule>((event, emit) => emit(FavoriteScheduleInitial()));
    on<LoadFavoriteSchedule>(_loadFavoriteSchedule);
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
          title: Errors.schedule,
          exception: 'scheduleModel == null',
        )));
        return;
      }

      emit(FavoriteScheduleLoaded(
        scheduleModel: scheduleModel,
        isNeedUpdate: event.isNeedUpdate,
        isFromMainPage: event.isFromMainPage,
      ));
    } catch (e, stack) {
      emit(FavoriteScheduleError(Logger.error(
        title: Errors.schedule,
        exception: e,
        stack: stack,
      )));
    }
  }

  Future<void> _openMainFavSchedule(
      OpenMainFavSchedule event, Emitter<FavoriteScheduleState> emit) async {
    final scheduleName = await _favoriteRepository.getMainFavScheduleName();
    if (scheduleName == null) return;

    add(LoadFavoriteSchedule(scheduleName, isFromMainPage: true));
  }
}
