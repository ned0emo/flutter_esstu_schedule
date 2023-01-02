import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:schedule/students/all_groups_bloc/all_groups_repository.dart';
import 'package:tuple/tuple.dart';

part 'all_groups_state.dart';

class AllGroupsCubit extends Cubit<AllGroupsState> {
  final AllGroupsRepository repository;
  int loadCounter = 0;
  int errorCounter = 0;
  bool continueFillsMaps = true;

  AllGroupsCubit({required this.repository}) : super(AllGroupsLoading());

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
  final zo1ScheduleMap = <String, Map<String, String>>{
    '1 курс': {},
    '2 курс': {},
    '3 курс': {},
    '4 курс': {},
    '5 курс': {},
    '6 курс': {},
  };
  final zo2ScheduleMap = <String, Map<String, String>>{
    '1 курс': {},
    '2 курс': {},
    '3 курс': {},
    '4 курс': {},
    '5 курс': {},
    '6 курс': {},
  };

  /// Загрузка сайтов со списком групп и добавление всех загруженных
  /// страниц в один лист.
  ///
  /// Заполнение мэпов по курсам с парами "Имя группы - Ссылка"
  Future<void> loadGroupList() async {
    final groupPageList = await repository.loadGroupsPages();

    continueFillsMaps = true;
    for (int i = 1; i < 7 && continueFillsMaps; i++) {
      _fillCourseGroupList(groupPageList[0], i, bakScheduleMap);
      _fillCourseGroupList(groupPageList[2], i, zo1ScheduleMap);
      _fillCourseGroupList(groupPageList[3], i, zo2ScheduleMap);
    }
    for (int i = 1; i < 5 && continueFillsMaps; i++) {
      _fillCourseGroupList(groupPageList[1], i, colScheduleMap);
    }
    for (int i = 1; i < 3 && continueFillsMaps; i++) {
      _fillCourseGroupList(groupPageList[1], i, magScheduleMap, courseFix: 4);
    }

    while (loadCounter < 24 && errorCounter < 50) {
      sleep(const Duration(microseconds: 100));
      errorCounter++;
    }
    if (errorCounter > 49) {
      continueFillsMaps = false;
    }

    if (continueFillsMaps) {
      emit(
        AllGroupsLoaded(),
      );
      //emit(StudentsAllGroupsLoaded());
    } else {
      emit(AllGroupsError());
    }
  }

  /// Создание списка пар "Группа - Ссылка" и добавление его в мэп
  /// Вызывается для каждого курса каждого типа обучения (баки, маги и т. д.)
  Future<void> _fillCourseGroupList(String pageText, int courseName,
      Map<String, Map<String, String>> scheduleMap,
      {int courseFix = 0}) async {
    final List<String> splittedPage = pageText.split('HREF="').skip(1).toList();

    for (int i = courseName - 1, emptinessCounter = 0;
        emptinessCounter < 3 && continueFillsMaps;
        i += 6) {
      String link = splittedPage[i].substring(0, splittedPage[i].indexOf('">'));
      String group = splittedPage[i].substring(
          splittedPage[i].indexOf('Roman">') + 7,
          splittedPage[i].indexOf('</'));

      if (group.length < 3) {
        emptinessCounter++;
      } else {
        scheduleMap['${courseName - courseFix} курс']?[group] = link;
      }
    }

    loadCounter++;
  }

  /// Выбор конкретного курса для заполнения списка групп.
  /// [typeLink2] нужен для заочников, иначе пустой.
  /// Переменная [courseType] должна принимать значения:
  ///
  /// 0 - бакалавры;
  /// 1 - колледж;
  /// 2 - маги;
  /// иначе - заочка.
  Future<void> selectCourse(String courseName, int courseType, String typeLink1,
      {String typeLink2 = ''}) async {
    final linkGroupMap = courseType == 0
        ? bakScheduleMap[courseName]
        : courseType == 1
            ? colScheduleMap[courseName]
            : courseType == 2
                ? magScheduleMap[courseName]
                : zo1ScheduleMap[courseName];

    if (linkGroupMap == null) {
      emit(AllGroupsError());
      return;
    }

    emit(CourseSelected(
      linkGroupMap: linkGroupMap,
      courseName: courseName,
      typeLink1: typeLink1,
      typeLink2: typeLink2,
      currentGroup: linkGroupMap.keys.first,
    ));
  }

  /// Смена группы в DropDownButton
  Future<void> selectGroup(String group) async {
    final currentState = state;
    if (currentState is CourseSelected) {
      emit(CourseSelected(
        linkGroupMap: currentState.linkGroupMap,
        courseName: currentState.courseName,
        typeLink1: currentState.typeLink1,
        typeLink2: currentState.typeLink2,
        currentGroup: group,
      ));
    }
  }
}
