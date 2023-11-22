import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/parser/students_parser.dart';
import 'package:schedule/core/static/errors.dart';
import 'package:schedule/core/static/logger.dart';
import 'package:schedule/core/static/students_type.dart';

part 'all_groups_event.dart';
part 'all_groups_state.dart';

class AllGroupsBloc extends Bloc<AllGroupsEvent, AllGroupsState> {
  final StudentsParser _parser;

  AllGroupsBloc(MainRepository repository, StudentsParser parser)
      : _parser = parser,
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

    final scheduleMap = await _parser.courseGroupLinkMap();

    if (scheduleMap == null) {
      emit(AllGroupsError(_parser.lastError ?? 'Ошибка'));
      return;
    }

    try {
      final typeKey = scheduleMap.keys.firstOrNull;
      final courseKey = scheduleMap[typeKey]?.keys.firstOrNull;
      final groupKey = scheduleMap[typeKey]?[courseKey]?.keys.firstOrNull;

      if (groupKey == null || courseKey == null) {
        emit(AllGroupsError(Logger.error(
          title: Errors.studentsNotFoundError,
          exception: 'studKey == null',
        )));
        return;
      }

      emit(
        AllGroupsLoaded(
            scheduleLinksMap: scheduleMap,
            studType: typeKey!,
            currentCourse: courseKey,
            currentGroup: groupKey,
            appBarTitle: '${_groupTypeRus(typeKey)}. $courseKey'),
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
        appBarTitle: '${_groupTypeRus(event.studType)}. ${event.courseName}',
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

  String _groupTypeRus(String type) => type == StudentsType.bak
      ? 'Бакалавриат'
      : type == StudentsType.mag
          ? 'Магистратура'
          : type == StudentsType.col
              ? 'Колледж'
              : 'Заочное';
}
