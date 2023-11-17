import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/parser.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/schedule_type.dart';

part 'search_list_event.dart';

part 'search_list_state.dart';

class SearchListBloc extends Bloc<SearchListEvent, SearchListState> {
  final MainRepository _searchRepository;
  final Parser _parser;

  final int _threadCount = 6;

  final List<String> _teachersLinks = [
    "/spezialitet/craspisanEdt.htm",
    "/bakalavriat/craspisanEdt.htm",
  ];

  final List<String> _teachersScheduleLinks = [
    "/spezialitet",
    "/bakalavriat",
  ];

  SearchListBloc(MainRepository repository, Parser parser)
      : _searchRepository = repository,
        _parser = parser,
        super(SearchInitial()) {
    on<LoadSearchList>(_loadSearchList);
    on<SearchInList>(_searchInList);
  }

  Future<void> _loadSearchList(
      LoadSearchList event, Emitter<SearchListState> emit) async {
    emit(SearchListLoading());

    final Map<String, List<String>>? scheduleLinksMap;

    ///Учебные группы
    if (event.scheduleType == ScheduleType.student) {
      scheduleLinksMap  = await _parser.groupMap();
      if(scheduleLinksMap == null){
        emit(SearchingError(Logger.error(
          title: Errors.scheduleError,
          exception: _parser.lastError,
        )));
        return;
      }
    }

    ///Препода
    else {
      scheduleLinksMap = {};
      final facultiesPages = [];
      try {
        for (String link in _teachersLinks) {
          facultiesPages.add(await _searchRepository.loadPage(link));
        }
      } catch (e, stack) {
        emit(SearchingError(Logger.error(
          title: Errors.scheduleError,
          exception: e,
          stack: stack,
        )));
        return;
      }

      int progress = 0;
      int errorCount = 0;
      int completedThreads = 0;
      int linksCount = 0;

      ///Многопоток реализован по аналогии с аудиториями
      Future<void> loadDepartmentPages(List<String> links) async {
        int localErrorCount = 0;
        for (String link in links) {
          try {
            final splittedPage = (await _searchRepository.loadPage(link))
                .split('ff00ff">')
                .skip(1);

            for (String teacherSection in splittedPage) {
              final teacherName = teacherSection
                  .substring(0, teacherSection.indexOf('<'))
                  .trim();

              if (scheduleLinksMap![teacherName] == null) {
                scheduleLinksMap[teacherName] = [];
              }
              scheduleLinksMap[teacherName]!.add(link);
            }
          } catch (e, stack) {
            Logger.warning(
              title: Errors.pageLoadingError,
              exception: e,
              stack: stack,
            );
            localErrorCount++;
          }

          progress++;
          if (localErrorCount > 4) {
            completedThreads++;
            errorCount += localErrorCount;
            return;
          }
        }

        completedThreads++;
      }

      final List<List<String>> departmentLinks =
          List.generate(_threadCount, (index) => []);

      int i = 0;
      for (String page in facultiesPages) {
        final splittedPage =
            page.replaceAll(RegExp(r"<!--.*-->"), '').split('href="').skip(1);

        int j = 0;
        for (String departmentSection in splittedPage) {
          final link =
              '${_teachersScheduleLinks[i]}/${departmentSection.substring(0, departmentSection.indexOf('">'))}';
          departmentLinks[j % _threadCount].add(link);
          j++;
        }
        linksCount += j;

        i++;
      }

      if (linksCount == 0) {
        emit(SearchingError(Logger.error(
          title: Errors.pageParsingError,
          exception: 'linksCount == 0',
        )));
        return;
      }

      int freezeCount = 0;
      int oldProgress = progress;
      for (int i = 0; i < _threadCount; i++) {
        loadDepartmentPages(departmentLinks[i]);
      }
      do {
        await Future.delayed(const Duration(milliseconds: 300));

        if (oldProgress == progress) {
          freezeCount++;
          if (freezeCount > 20) {
            emit(SearchListLoading(
              percents: (progress / linksCount * 100).toInt(),
              message:
                  'Загрузка длится слишком долго. Возможно, что-то пошло не так...',
            ));
          }
          continue;
        } else {
          oldProgress = progress;
          freezeCount = 0;
        }
        emit(
            SearchListLoading(percents: (progress / linksCount * 100).toInt()));
      } while (completedThreads < _threadCount);

      if (errorCount > 8) {
        emit(SearchingError(Logger.error(
          title: Errors.scheduleError,
          exception: 'errorsCount > 8',
        )));
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
}
