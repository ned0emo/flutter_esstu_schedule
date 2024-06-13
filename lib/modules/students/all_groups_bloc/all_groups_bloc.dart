import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/logger/custom_exception.dart';
import 'package:schedule/core/logger/logger.dart';
import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/parser/students_parser.dart';
import 'package:schedule/core/logger/errors.dart';
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

    try {
      final scheduleMap = await _parser.courseGroupLinkMap();

      final typeKey = scheduleMap.keys.firstOrNull;
      final courseKey = scheduleMap[typeKey]?.keys.firstOrNull;
      final groupKey = scheduleMap[typeKey]?[courseKey]?.keys.firstOrNull;

      if (groupKey == null || courseKey == null) {
        emit(const AllGroupsError(
            '${Errors.studentsNotFound} studKey == null'));
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
    } on CustomException catch (e) {
      emit(AllGroupsError(e.message));
    } catch (e, stack) {
      Logger.error(title: Errors.studentsSchedule, exception: e, stack: stack);
      emit(AllGroupsError('Ошибка: ${e.runtimeType}'));
    }
  }

  Future<void> _selectCourse(
      SelectCourse event, Emitter<AllGroupsState> emit) async {
    final currentState = state;

    if (currentState is AllGroupsLoaded) {
      emit(AllGroupsLoading(appBarTitle: currentState.appBarTitle));

      final courseMap =
          currentState.courseMap(event.courseName, event.studType);

      /// Такт удаляются все пустые записи, но пусть будет
      if (courseMap.isEmpty) {
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
