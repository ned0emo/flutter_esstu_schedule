import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/parser.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_update_event.dart';

part 'favorite_update_state.dart';

class FavoriteUpdateBloc
    extends Bloc<FavoriteUpdateEvent, FavoriteUpdateState> {
  final FavoriteRepository _favoriteRepository;
  final Parser _parser;

  FavoriteUpdateBloc(FavoriteRepository repository, Parser parser)
      : _favoriteRepository = repository,
        _parser = parser,
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
      final scheduleModel = await _parser.scheduleModel(
        link1: event.scheduleModel.link1!,
        link2: event.scheduleModel.link2,
        scheduleName: event.scheduleModel.name,
        scheduleType: event.scheduleModel.type,
        isZo: event.scheduleModel.isZo,
      );

      if (scheduleModel == null) {
        emit(FavoriteScheduleUpdateError('Ошибка обновления расписания'));
        return;
      }

      final oldModelStr = event.scheduleModel.toString();
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
}
