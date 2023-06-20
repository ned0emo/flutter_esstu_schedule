part of 'search_list_bloc.dart';

@immutable
abstract class SearchListState {}

class SearchInitial extends SearchListState {}

class SearchListLoading extends SearchListState {
  final int? percents;
  final String? message;

  SearchListLoading({this.percents, this.message});
}

class SearchListLoaded extends SearchListState {
  final Map<String, List<String>> scheduleLinksMap;
  final String? searchText;
  final List<String>? searchedList;

  SearchListLoaded({
    required this.scheduleLinksMap,
    this.searchText,
    this.searchedList,
  });

  SearchListLoaded copyWith({
    Map<String, List<String>>? scheduleLinksMap,
    String? searchText,
    List<String>? searchedList,
  }) {
    return SearchListLoaded(
      scheduleLinksMap: scheduleLinksMap ?? this.scheduleLinksMap,
      searchText: searchText ?? this.searchText,
      searchedList: searchedList ?? this.searchedList,
    );
  }
}

class SearchingError extends SearchListState {
  final String message;

  SearchingError(this.message);
}
