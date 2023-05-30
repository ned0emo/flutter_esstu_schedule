import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/modules/favorite/models/favorite_schedule_model.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_button_event.dart';

part 'favorite_button_state.dart';

class FavoriteButtonBloc extends Bloc<FavoriteButtonEvent, FavoriteButtonState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteButtonBloc(FavoriteRepository repository)
      : _favoriteRepository = repository,
        super(FavoriteInitial()) {
    on<SaveSchedule>(_saveSchedule);
    on<CheckSchedule>(_checkSchedule);
    on<DeleteSchedule>(_deleteSchedule);
  }

  Future<void> _saveSchedule(
      SaveSchedule event, Emitter<FavoriteButtonState> emit) async {
    await _favoriteRepository.saveSchedule(
        event.name,
        FavoriteScheduleModel(
          name: event.name,
          scheduleType: event.scheduleType,
          link1: event.link1,
          link2: event.link2,
          scheduleList: event.scheduleList,
          daysOfWeekList: event.daysOfWeekList,
        ).toString());

    if (await _favoriteRepository.checkSchedule(event.name)) {
      emit(FavoriteExist());
    } else {
      emit(FavoriteDoesNotExist());
    }
  }

  Future<void> _deleteSchedule(
      DeleteSchedule event, Emitter<FavoriteButtonState> emit) async {
    await _favoriteRepository.deleteSchedule(event.name);

    if (await _favoriteRepository.checkSchedule(event.name)) {
      emit(FavoriteExist());
    } else {
      emit(FavoriteDoesNotExist());
    }
  }

  Future<void> _checkSchedule(
      CheckSchedule event, Emitter<FavoriteButtonState> emit) async {
    if (await _favoriteRepository.checkSchedule(event.name)) {
      emit(FavoriteExist(isNeedSnackBar: false));
    } else {
      emit(FavoriteDoesNotExist(isNeedSnackBar: false));
    }
  }
}
