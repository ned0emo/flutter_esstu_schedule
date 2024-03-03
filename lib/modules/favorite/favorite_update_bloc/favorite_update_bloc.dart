import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/logger/custom_exception.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/parser.dart';
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
      final scheduleModel = await _parser.updateSchedule(
        link1: event.scheduleModel.link1!,
        link2: event.scheduleModel.link2,
        scheduleName: event.scheduleModel.name,
        scheduleType: event.scheduleModel.type,
        isZo: event.scheduleModel.isZo,
      );

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
    } on CustomException catch (e) {
      emit(FavoriteScheduleUpdateError(e.message));
    } catch (e) {
      emit(FavoriteScheduleUpdateError('Ошибка: ${e.runtimeType}'));
    }
  }
}
