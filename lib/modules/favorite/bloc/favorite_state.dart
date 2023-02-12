part of 'favorite_bloc.dart';

@immutable
abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteListLoading extends FavoriteState {}

class FavoriteListLoaded extends FavoriteState {}

class FavoriteScheduleLoad extends FavoriteState {}

class FavoriteListError extends FavoriteState {}

class FavoriteExist extends FavoriteState {
  final bool isNeedSnackBar;

  FavoriteExist({this.isNeedSnackBar = true});
}

class FavoriteDoesNotExist extends FavoriteState{
  final bool isNeedSnackBar;

  FavoriteDoesNotExist({this.isNeedSnackBar = true});
}

class FavoriteScheduleError extends FavoriteState {}
