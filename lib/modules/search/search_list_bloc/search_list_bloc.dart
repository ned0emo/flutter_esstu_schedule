import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:schedule/modules/search/search_repository.dart';

part 'search_list_event.dart';

part 'search_list_state.dart';

class SearchListBloc extends Bloc<SearchListEvent, SearchListState> {
  final SearchRepository _searchRepository;
  final int threadCount = 6;

  final List<String> studentsLinks = [
    '/bakalavriat/raspisan.htm',
    '/spezialitet/raspisan.htm',
    '/zo1/raspisan.htm',
    '/zo2/raspisan.htm',
  ];

  final List<String> studentsScheduleLinks = [
    '/bakalavriat',
    '/spezialitet',
    '/zo1',
    '/zo2',
  ];

  final List<String> teachersLinks = [
    "/spezialitet/craspisanEdt.htm",
    "/bakalavriat/craspisanEdt.htm",
  ];

  final List<String> teachersScheduleLinks = [
    "/spezialitet",
    "/bakalavriat",
  ];

  ///Маги, колледж
  final magLink = "/spezialitet/craspisanEdt.htm";

  ///Баки, специалитет
  final bakLink = "/bakalavriat/craspisanEdt.htm";

  SearchListBloc(SearchRepository repository)
      : _searchRepository = repository,
        super(SearchInitial()) {
    on<LoadSearchList>(_loadSearchList);
    on<SearchInList>(_searchInList);
  }

  Future<void> _loadSearchList(
      LoadSearchList event, Emitter<SearchListState> emit) async {
    emit(SearchListLoading());

    final Map<String, List<String>> scheduleLinksMap = {};

    ///Учебные группы
    if (event.scheduleType == ScheduleType.student) {
      final schedulePages = [];

      for (String link in studentsLinks) {
        schedulePages.add(await _searchRepository.loadPage(link));
      }

      try {
        int i = 0;
        for (String page in schedulePages) {
          final splittedPage = page.split('HREF="').skip(1);
          for (String groupSection in splittedPage) {
            if (!groupSection.contains(RegExp(r'[0-9]'))) break;

            final name = groupSection.substring(
                groupSection.indexOf('n">') + 3, groupSection.indexOf('</F'));
            if (!name.contains(RegExp(r'[0-9]'))) {
              continue;
            }
            final link =
                '${studentsScheduleLinks[i]}/${groupSection.substring(0, groupSection.indexOf('>'))}';

            if (scheduleLinksMap[name] == null) scheduleLinksMap[name] = [];
            scheduleLinksMap[name]!.add(link);
          }
          i++;
        }
      } catch (e) {
        emit(SearchingError(
            'Ошибка загрузки списка учебных групп:\n${e.runtimeType}'));
        return;
      }
    }
    ///Препода
    else {
      final facultiesPages = [];
      for (String link in teachersLinks) {
        facultiesPages.add(await _searchRepository.loadPage(link));
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

              if (scheduleLinksMap[teacherName] == null) {
                scheduleLinksMap[teacherName] = [];
              }
              scheduleLinksMap[teacherName]!.add(link);
            }
          } catch (e) {
            print(e.runtimeType);
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
          List.generate(threadCount, (index) => []);

      int i = 0;
      for (String page in facultiesPages) {
        final splittedPage =
            page.replaceAll(RegExp(r"<!--.*-->"), '').split('href="').skip(1);

        int j = 0;
        for (String departmentSection in splittedPage) {
          final link =
              '${teachersScheduleLinks[i]}/${departmentSection.substring(0, departmentSection.indexOf('">'))}';
          departmentLinks[j % threadCount].add(link);
          j++;
        }
        linksCount += j;

        i++;
      }

      if (linksCount == 0) {
        emit(SearchingError('Ошибка загрузки списка преподавателей'));
        return;
      }

      int freezeCount = 0;
      int oldProgress = progress;
      for (int i = 0; i < threadCount; i++) {
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
      } while (completedThreads < threadCount);

      if (errorCount > 8) {
        emit(SearchingError('Ошибка загрузки страниц расписания кафедр'));
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
            namesList: namesList.take(10).toList()..sort()));
      } catch (e) {
        emit(SearchingError('Ошибка поиска:\n${e.runtimeType}'));
      }
    }
  }
}
