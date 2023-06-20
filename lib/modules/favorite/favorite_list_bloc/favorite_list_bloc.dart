import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/errors.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_list_event.dart';

part 'favorite_list_state.dart';

class FavoriteListBloc extends Bloc<FavoriteListEvent, FavoriteListState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteListBloc(FavoriteRepository repository)
      : _favoriteRepository = repository,
        super(FavoriteListInitial()) {
    on<LoadFavoriteList>(_loadFavoriteList);
    on<ClearAllSchedule>(_clearAllSchedule);
    on<DeleteScheduleFromList>(_deleteSchedule);
  }

  Future<void> _loadFavoriteList(
      LoadFavoriteList event, Emitter<FavoriteListState> emit) async {
    emit(FavoriteListLoading());

    try {
      final list = await _favoriteRepository.getFavoriteList();
      if (list.isEmpty) {
        emit(FavoriteListLoaded(const {}));
        return;
      }

      final Map<String, List<String>> favoriteListMap = {
        ScheduleType.teacher: [],
        ScheduleType.student: [],
        ScheduleType.classroom: [],
        '': [],
      };

      for (String scheduleName in list) {
        if (!scheduleName.contains('|')) {
          favoriteListMap['']!.add(scheduleName);
        } else {
          try {
            favoriteListMap[
                    scheduleName.substring(0, scheduleName.indexOf('|'))]!
                .add(scheduleName.substring(scheduleName.indexOf('|') + 1));
          } catch (e, stack) {
            Logger.warning(
              title: 'Ошибка определения типа расписания',
              exception: e,
              stack: stack,
            );
            favoriteListMap['']!.add(scheduleName);
          }
        }
      }

      favoriteListMap.removeWhere((key, value) => value.isEmpty);
      emit(FavoriteListLoaded(favoriteListMap));
    } catch (e, stack) {
      emit(FavoriteListError(Logger.error(
        title: Errors.scheduleError,
        exception: e,
        stack: stack,
      )));
    }
  }

  Future<void> _clearAllSchedule(
      ClearAllSchedule event, Emitter<FavoriteListState> emit) async {
    await _favoriteRepository.clearSchedule();
    emit(FavoriteListLoaded(const {}));
  }

  Future<void> _deleteSchedule(
      DeleteScheduleFromList event, Emitter<FavoriteListState> emit) async {
    await _favoriteRepository
        .deleteSchedule('${event.scheduleType}|${event.scheduleName}');
    add(LoadFavoriteList());
  }
}
