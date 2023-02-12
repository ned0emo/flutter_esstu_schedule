import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/modules/favorite/models/favorite_schedule_model.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_event.dart';

part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteBloc(FavoriteRepository repository)
      : _favoriteRepository = repository,
        super(FavoriteInitial()) {
    on<LoadFavoriteList>(_loadFavoriteList);
    on<SaveSchedule>(_saveSchedule);
    on<CheckSchedule>(_checkSchedule);
    on<DeleteSchedule>(_deleteSchedule);
  }

  Future<void> _loadFavoriteList(
      LoadFavoriteList event, Emitter<FavoriteState> emit) async {
    //emit(FavoriteListLoading());
  }

  Future<void> _saveSchedule(
      SaveSchedule event, Emitter<FavoriteState> emit) async {
    await _favoriteRepository.saveSchedule(
        event.name,
        FavoriteScheduleModel(
          name: event.name,
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
      DeleteSchedule event, Emitter<FavoriteState> emit) async {
    await _favoriteRepository.deleteSchedule(event.name);

    if (await _favoriteRepository.checkSchedule(event.name)) {
      emit(FavoriteExist());
    } else {
      emit(FavoriteDoesNotExist());
    }
  }

  Future<void> _checkSchedule(
      CheckSchedule event, Emitter<FavoriteState> emit) async {
    if (await _favoriteRepository.checkSchedule(event.name)) {
      emit(FavoriteExist(isNeedSnackBar: false));
    } else {
      emit(FavoriteDoesNotExist(isNeedSnackBar: false));
    }
  }
}
