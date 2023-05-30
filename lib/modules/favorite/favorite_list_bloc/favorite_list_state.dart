part of 'favorite_list_bloc.dart';

@immutable
abstract class FavoriteListState {}

class FavoriteListInitial extends FavoriteListState {}

class FavoriteListLoading extends FavoriteListState {}

class FavoriteListLoaded extends FavoriteListState {
  final List<String> favoriteList;

  FavoriteListLoaded(this.favoriteList);
}

class FavoriteListError extends FavoriteListState {
  final String message;

  FavoriteListError(this.message);
}
