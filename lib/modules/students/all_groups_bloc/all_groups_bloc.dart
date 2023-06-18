import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/schedule_links.dart';
import 'package:schedule/core/students_type.dart';
import 'package:schedule/modules/home/main_repository.dart';

part 'all_groups_state.dart';

part 'all_groups_event.dart';

class AllGroupsBloc extends Bloc<AllGroupsEvent, AllGroupsState> {
  final MainRepository _repository;

  AllGroupsBloc(MainRepository repository)
      : _repository = repository,
        super(AllGroupsLoading()) {
    on<LoadAllGroups>(_loadGroupList);
    on<SelectCourse>(_selectCourse);
    on<SelectGroup>(_selectGroup);
  }

  /// Загрузка сайтов со списком групп и добавление всех загруженных
  /// страниц в один лист.
  ///
  /// Заполнение мэпов по курсам с парами "Имя группы - Ссылка"
  Future<void> _loadGroupList(
      LoadAllGroups event, Emitter<AllGroupsState> emit) async {
    emit(AllGroupsLoading());

    final bakScheduleMap = <String, Map<String, String>>{
      '1 курс': {},
      '2 курс': {},
      '3 курс': {},
      '4 курс': {},
      '5 курс': {},
      '6 курс': {},
    };
    final colScheduleMap = <String, Map<String, String>>{
      '1 курс': {},
      '2 курс': {},
      '3 курс': {},
      '4 курс': {},
    };
    final magScheduleMap = <String, Map<String, String>>{
      '1 курс': {},
      '2 курс': {},
    };
    final zoScheduleMap = <String, Map<String, String>>{
      '1 курс': {},
      '2 курс': {},
      '3 курс': {},
      '4 курс': {},
      '5 курс': {},
      '6 курс': {},
    };

    ///Параллельная обработка студенческих страниц с группами
    int completedThreadsCount = 0;
    Future<void> createGroupLinkMap(String page, String type) async {
      try {
        final splittedPage = page.split('HREF="').skip(1).toList();
        final prefix = type == StudentsType.bak
            ? ScheduleLinks.bakPrefix
            : type == StudentsType.mag
                ? ScheduleLinks.magPrefix
                : type == StudentsType.zo1
                    ? ScheduleLinks.zo1Prefix
                    : ScheduleLinks.zo2Prefix;

        int emptinessCounter = 0;
        for (int i = 0; i < splittedPage.length; i++) {
          if (emptinessCounter > 11) {
            break;
          }

          final name = splittedPage[i]
              .substring(splittedPage[i].indexOf('n">') + 3,
                  splittedPage[i].indexOf('</FONT'))
              .trim();
          if (!name.contains(RegExp(r'[0-9]'))) {
            emptinessCounter++;
            continue;
          }
          emptinessCounter = 0;

          final link = prefix +
              splittedPage[i].substring(0, splittedPage[i].indexOf('">'));

          if (type == StudentsType.mag) {
            final currentCourse = i % 6 + 1;
            if (currentCourse < 5) {
              colScheduleMap['$currentCourse курс']![name] = link;
            } else {
              magScheduleMap['${currentCourse - 4} курс']![name] = link;
            }
          } else if (type == StudentsType.bak) {
            bakScheduleMap['${i % 6 + 1} курс']![name] = link;
          } else {
            zoScheduleMap['${i % 6 + 1} курс']![name] = link;
          }
        }

        completedThreadsCount++;
      } catch (e) {
        Logger.addLog(
          Logger.warning,
          'Ошибка добавления пары "группа: ссылка"',
          'Неизвестная ошибка. Тип: ${e.runtimeType}',
        );
        completedThreadsCount++;
      }
    }

    try {
      createGroupLinkMap(await _repository.loadPage(ScheduleLinks.allBakGroups),
          StudentsType.bak);
      createGroupLinkMap(await _repository.loadPage(ScheduleLinks.allMagGroups),
          StudentsType.mag);
      createGroupLinkMap(await _repository.loadPage(ScheduleLinks.allZo1Groups),
          StudentsType.zo1);
      createGroupLinkMap(await _repository.loadPage(ScheduleLinks.allZo2Groups),
          StudentsType.zo2);

      int longDelayCheck = 0;
      while (completedThreadsCount < 4 && longDelayCheck < 30) {
        await Future.delayed(const Duration(microseconds: 300));
        longDelayCheck++;
      }

      final initCourse = bakScheduleMap.keys.first;
      if (bakScheduleMap[initCourse]!.keys.isEmpty) {
        Logger.addLog(
          Logger.info,
          'Не найдено групп с расписанием',
          'bakScheduleMap[initCourse]!.keys.isEmpty',
        );

        emit(AllGroupsError(
            'Хмм... Кажется, здесь нет групп с заполненным расписанием'));
        return;
      }

      if (longDelayCheck < 30) {
        emit(AllGroupsLoaded(
          bakScheduleMap: bakScheduleMap,
          magScheduleMap: magScheduleMap,
          colScheduleMap: colScheduleMap,
          zoScheduleMap: zoScheduleMap,
          studType: StudentsType.bak,
          currentCourse: initCourse,
          currentGroup: bakScheduleMap[initCourse]!.keys.first,
        ));
      } else {
        Logger.addLog(
          Logger.error,
          'Ошибка обработки страниц с учебными группами',
          'Обработка страниц длилась слишком долго',
        );

        emit(AllGroupsError(
            'Ошибка обработки страниц с учебными группами\nОбработка страниц длилась слишком долго'));
      }
    } on SocketException catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка загрузки страниц с учебными группами',
        'Отсутствие интернета или недоступность сайта:\n${e.message}',
      );
      emit(AllGroupsError(
          'Ошибка загрузки страниц с учебными группами\n${e.message}'
          '\nВозможно, проблемы с интернетом или с доступом к сайту'));
    } catch (e) {
      Logger.addLog(
        Logger.error,
        'Ошибка загрузки страниц с учебными группами',
        'Неизвестная ошибка. Тип:\n${e.runtimeType}',
      );
      emit(AllGroupsError(
          'Ошибка загрузки страниц с учебными группами\n${e.runtimeType}'));
    }
  }

  Future<void> _selectCourse(
      SelectCourse event, Emitter<AllGroupsState> emit) async {
    final currentState = state;

    if (currentState is AllGroupsLoaded) {
      emit(AllGroupsLoading());

      final courseMap =
          currentState.courseMap(event.courseName, event.studType);
      if (courseMap.isEmpty) {
        Logger.addLog(
          Logger.info,
          'Не найдено групп с расписанием',
          'AllGroupsLoaded().courseMap is empty',
        );

        emit(currentState.copyWith(
            warningMessage:
                'Хмм... Кажется, здесь нет групп с заполненным расписанием'));
        return;
      }

      final initGroup = courseMap.keys.first;
      emit(currentState.copyWith(
          currentCourse: event.courseName,
          studType: event.studType,
          currentGroup: initGroup));
    }
  }

  Future<void> _selectGroup(
      SelectGroup event, Emitter<AllGroupsState> emit) async {
    final currentState = state;
    if (currentState is AllGroupsLoaded) {
      emit(currentState.copyWith(currentGroup: event.groupName));
    }
  }
}
