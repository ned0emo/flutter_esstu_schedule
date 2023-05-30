import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_list_event.dart';

part 'favorite_list_state.dart';

class FavoriteListBloc extends Bloc<FavoriteListEvent, FavoriteListState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteListBloc(FavoriteRepository repository)
      : _favoriteRepository = repository,
        super(FavoriteListInitial()) {
    on<LoadFavoriteList>(_loadFavoriteList);
  }

  Future<void> _loadFavoriteList(
      LoadFavoriteList event, Emitter<FavoriteListState> emit) async {
    emit(FavoriteListLoading());

    try {
      final list = await _favoriteRepository.getFavoriteList();
      emit(FavoriteListLoaded(list));
    } catch (e) {
      emit(FavoriteListError(e.runtimeType.toString()));
    }
  }
}
