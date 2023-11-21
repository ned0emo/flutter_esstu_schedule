import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/parser/students_parser.dart';
import 'package:schedule/core/parser/teachers_parser.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/schedule_type.dart';

part 'search_list_event.dart';
part 'search_list_state.dart';

class SearchListBloc extends Bloc<SearchListEvent, SearchListState> {
  final TeachersParser _teachersParser;
  final StudentsParser _studentsParser;

  final _streamController = StreamController<Map<String, String>>();

  SearchListBloc(TeachersParser teachersParser, StudentsParser studentsParser)
      : _teachersParser = teachersParser, _studentsParser = studentsParser,
        super(SearchInitial()) {
    on<LoadSearchList>(_loadSearchList);
    on<SearchInList>(_searchInList);
  }

  Future<void> _loadSearchList(
      LoadSearchList event, Emitter<SearchListState> emit) async {
    emit(SearchListLoading());

    final Map<String, List<String>>? scheduleLinksMap;

    if (event.scheduleType == ScheduleType.student) {
      ///Учебные группы
      scheduleLinksMap = await _studentsParser.groupLinkMap();
      if (scheduleLinksMap == null) {
        emit(SearchingError(Logger.error(
          title: Errors.scheduleError,
          exception: _teachersParser.lastError,
        )));
        return;
      }
    } else {
      ///Препода

      _streamController.stream.listen((event) {
        emit(SearchListLoading(
          percents: event['percents'] ?? '0',
          message: event['message'] ?? '',
        ));
      });

      scheduleLinksMap = await _teachersParser.teachersLinksMap(_streamController);
      await _streamController.close();

      if (scheduleLinksMap == null) {
        emit(SearchingError(_teachersParser.lastError ?? 'Ошибка'));
        return;
      }
    }

    emit(SearchListLoaded(scheduleLinksMap: scheduleLinksMap));
  }

  Future<void> _searchInList(
      SearchInList event, Emitter<SearchListState> emit) async {
    final currentState = state;

    if (currentState is SearchListLoaded) {
      try {
        final namesList = currentState.scheduleLinksMap.keys.toList();
        namesList.removeWhere((element) =>
            !element.toUpperCase().contains(event.searchText.toUpperCase()));
        emit(currentState.copyWith(
            searchedList: namesList.take(15).toList()..sort()));
      } catch (e, stack) {
        emit(SearchingError(Logger.error(
          title: Errors.searchError,
          exception: e,
          stack: stack,
        )));
      }
    }
  }

  @override
  Future<void> close() async {
    await _streamController.close();
    return super.close();
  }
}
