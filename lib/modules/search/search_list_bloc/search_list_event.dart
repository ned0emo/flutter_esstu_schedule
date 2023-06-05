part of 'search_list_bloc.dart';

@immutable
abstract class SearchListEvent {}

class LoadSearchList extends SearchListEvent {
  final String scheduleType;

  LoadSearchList(this.scheduleType);
}

class SearchInList extends SearchListEvent{
  final String searchText;

  SearchInList(this.searchText);
}
