import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger/custom_exception.dart';
import 'package:schedule/core/main_repository.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/parser.dart';
import 'package:schedule/core/parser/students_parser.dart';
import 'package:schedule/core/static/schedule_type.dart';

part 'current_group_event.dart';
part 'current_group_state.dart';

class CurrentGroupBloc extends Bloc<CurrentGroupEvent, CurrentGroupState> {
  final MainRepository _repository;
  final Parser _parser;

  CurrentGroupBloc(MainRepository repository, StudentsParser parser)
      : _repository = repository,
        _parser = parser,
        super(CurrentGroupInitial()) {
    on<LoadGroup>(_loadGroup);
  }

  Future<void> _loadGroup(
      LoadGroup event, Emitter<CurrentGroupState> emit) async {
    emit(CurrentGroupLoading());

    try {
      final page = await _repository.loadPage(event.link);
      final currentScheduleModel = await _parser.scheduleModel(
        link1: event.link,
        page1: page,
        scheduleName: event.scheduleName,
        scheduleType: ScheduleType.student,
        isZo: event.isZo,
      );

      String? groupNameOnPage = RegExp(r'#ff00ff">.*</P').firstMatch(page)?[0];
      if (groupNameOnPage != null) {
        groupNameOnPage = groupNameOnPage
            .replaceAll('#ff00ff">', '')
            .replaceAll('</P', '')
            .trim();
      }

      final message = groupNameOnPage == event.scheduleName
          ? null
          : 'Загруженное расписание может не соответствовать выбранной группе.\n\n'
              'Выбранная группа: ${event.scheduleName}\n'
              'Загруженная группа: $groupNameOnPage';

      emit(CurrentGroupLoaded(
        name: event.scheduleName,
        scheduleModel: currentScheduleModel,
        message: message,
      ));
    } on CustomException catch (e) {
      emit(CurrentGroupError(e.message));
    } catch (e) {
      emit(CurrentGroupError('Ошибка: ${e.runtimeType}'));
    }
  }
}
