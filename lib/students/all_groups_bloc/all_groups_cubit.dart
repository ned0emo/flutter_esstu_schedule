import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/students/all_groups_bloc/all_groups_repository.dart';
part 'all_groups_state.dart';

class AllGroupsCubit extends Cubit<AllGroupsState> {
  final AllGroupsRepository repository;
  int weekNumber = 0;
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
  final zoScheduleMap = <String, Map<String, String>>{
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
    //TODO Возможно, надо перенести в основной кубит
    //Подумать над правильным распознаванием при смещении номера на сайте
    await Jiffy.locale('ru');
    weekNumber = (Jiffy().week + 1) % 2;

    final groupPageList = await repository.loadGroupsPages();

    continueFillsMaps = true;
    for (int i = 1; i < 7 && continueFillsMaps; i++) {
      _fillCourseGroupList(groupPageList[0], i, bakScheduleMap);
      _fillCourseGroupList(groupPageList[2], i, zoScheduleMap,
          linkPrefix: '/zo1/');
      _fillCourseGroupList(groupPageList[3], i, zoScheduleMap,
          linkPrefix: '/zo2/');
    }
    for (int i = 1; i < 5 && continueFillsMaps; i++) {
      _fillCourseGroupList(groupPageList[1], i, colScheduleMap);
    }
    for (int i = 5; i < 7 && continueFillsMaps; i++) {
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
      emit(AllGroupsLoaded());
    } else {
      emit(AllGroupsError());
    }
  }

  /// Создание списка пар "Группа - Ссылка" и добавление его в мэп
  /// Вызывается для каждого курса каждого типа обучения (баки, маги и т. д.)
  ///
  /// [columnNumber] - номер столбца на странице расписания. Так завелось, что
  /// он от 1 до 6. Но по индексам нужно от 0 до 5, потому минус один в цикле хы
  ///
  /// Ссылка имеет шаблон циферка.htm
  ///
  /// Для заочки перед ней нужно добавить zo1/ или zo2/
  Future<void> _fillCourseGroupList(String pageText, int columnNumber,
      Map<String, Map<String, String>> scheduleMap,
      {int courseFix = 0, String linkPrefix = ''}) async {
    final List<String> splittedPage = pageText.split('HREF="').skip(1).toList();

    for (int i = columnNumber - 1, emptinessCounter = 0;
        emptinessCounter < 3 && continueFillsMaps && i < splittedPage.length;
        i += 6) {
      String link = splittedPage[i].substring(0, splittedPage[i].indexOf('">'));
      String group = splittedPage[i].substring(
          splittedPage[i].indexOf('Roman">') + 7,
          splittedPage[i].indexOf('</'));

      if (group.length < 3) {
        if (group.contains('.')) {
          continue;
        }
        emptinessCounter++;
      } else if (group.contains('...')) {
        continue;
      } else {
        scheduleMap['${columnNumber - courseFix} курс']?[group] =
            linkPrefix + link;
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
                : zoScheduleMap[courseName];

    if (linkGroupMap == null) {
      emit(AllGroupsError());
      return;
    }

    if (linkGroupMap.isEmpty) {
      emit(AllGroupsError(
          errorMessage:
              'Хмм... Кажется, здесь нет групп с заполненным расписанием'));
      return;
    }

    emit(CourseSelected(
      linkGroupMap: linkGroupMap,
      courseName: courseName,
      typeLink1: typeLink1,
      typeLink2: typeLink2,
      currentGroup: linkGroupMap.keys.first,
      weekNumber: weekNumber,
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
        weekNumber: currentState.weekNumber,
      ));
    }
  }
}
