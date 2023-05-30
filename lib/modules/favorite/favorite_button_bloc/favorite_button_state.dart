part of 'favorite_button_bloc.dart';

@immutable
abstract class FavoriteButtonState {}

class FavoriteInitial extends FavoriteButtonState {}

class FavoriteExist extends FavoriteButtonState {
  final bool isNeedSnackBar;

  FavoriteExist({this.isNeedSnackBar = true});
}

class FavoriteDoesNotExist extends FavoriteButtonState{
  final bool isNeedSnackBar;

  FavoriteDoesNotExist({this.isNeedSnackBar = true});
}
