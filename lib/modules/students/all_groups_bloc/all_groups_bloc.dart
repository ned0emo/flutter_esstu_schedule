import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/schedule_links.dart';
import 'package:schedule/core/static/students_type.dart';
import 'package:schedule/modules/home/main_repository.dart';

part 'all_groups_event.dart';

part 'all_groups_state.dart';

class AllGroupsBloc extends Bloc<AllGroupsEvent, AllGroupsState> {
  final MainRepository _repository;

  AllGroupsBloc(MainRepository repository)
      : _repository = repository,
        super(const AllGroupsLoading()) {
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
    emit(const AllGroupsLoading());

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
      } catch (e, stack) {
        Logger.warning(
          title: Errors.pageLoadingError,
          exception: e,
          stack: stack,
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

      if (longDelayCheck > 29) {
        emit(AllGroupsError(Logger.error(
          title: Errors.scheduleError,
          exception: 'Обработка страниц длилась слишком долго',
        )));
        return;
      }

      ///Для поиска первого существующего расписания
      final coursesMap = {
        StudentsType.bak: bakScheduleMap,
        StudentsType.col: colScheduleMap,
        StudentsType.mag: magScheduleMap,
        StudentsType.zo1: zoScheduleMap,
        //StudentsType.zo2: zoScheduleMap,
      };
      Map<String, Map<String, String>>? initialScheduleMap;
      String? currentCourse;
      String? initialStudType;

      void getInitialMap(
        String studKey,
        Map<String, Map<String, String>> studMap,
      ) {
        for (var key in studMap.keys) {
          if (studMap[key]!.isNotEmpty) {
            initialScheduleMap = studMap;
            currentCourse = key;
            initialStudType = studKey;

            break;
          }
        }
      }

      for (var key in coursesMap.keys) {
        coursesMap[key]!.removeWhere((k, v) => coursesMap[key]![k]!.isEmpty);
        getInitialMap(key, coursesMap[key]!);
        if (initialScheduleMap != null) break;
      }

      if (initialScheduleMap == null) {
        emit(AllGroupsError(Logger.error(
          title: Errors.studentsNotFoundError,
          exception: 'initialScheduleMap == null',
        )));
        return;
      }

      emit(
        AllGroupsLoaded(
            bakScheduleMap: bakScheduleMap,
            magScheduleMap: magScheduleMap,
            colScheduleMap: colScheduleMap,
            zoScheduleMap: zoScheduleMap,
            studType: initialStudType!,
            currentCourse: currentCourse!,
            currentGroup: initialScheduleMap![currentCourse]!.keys.first,
            appBarTitle:
                '${_groupTypeString(initialStudType!)}. $currentCourse'),
      );
    } catch (e, stack) {
      emit(AllGroupsError(Logger.error(
          title: Errors.scheduleError, exception: e, stack: stack)));
    }
  }

  Future<void> _selectCourse(
      SelectCourse event, Emitter<AllGroupsState> emit) async {
    final currentState = state;

    if (currentState is AllGroupsLoaded) {
      emit(AllGroupsLoading(appBarTitle: currentState.appBarTitle));

      final courseMap =
          currentState.courseMap(event.courseName, event.studType);
      if (courseMap.isEmpty) {
        Logger.info(
          title: Errors.studentsNotFoundError,
          exception: 'AllGroupsLoaded().courseMap is empty',
        );

        emit(currentState.copyWith(
            currentCourse: event.courseName,
            warningMessage:
                'Хмм... Кажется, здесь нет групп с заполненным расписанием'));
        return;
      }

      emit(currentState.copyWith(
        currentCourse: event.courseName,
        studType: event.studType,
        currentGroup: courseMap.keys.first,
        appBarTitle: '${_groupTypeString(event.studType)}. ${event.courseName}',
      ));
    }
  }

  Future<void> _selectGroup(
      SelectGroup event, Emitter<AllGroupsState> emit) async {
    final currentState = state;
    if (currentState is AllGroupsLoaded) {
      emit(currentState.copyWith(currentGroup: event.groupName));
    }
  }

  String _groupTypeString(String type) => type == StudentsType.bak
      ? 'Бакалавриат'
      : type == StudentsType.mag
          ? 'Магистратура'
          : type == StudentsType.col
              ? 'Колледж'
              : 'Заочное';
}
