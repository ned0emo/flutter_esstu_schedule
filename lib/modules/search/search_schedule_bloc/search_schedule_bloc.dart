import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/logger/custom_exception.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/parser/parser.dart';

part 'search_schedule_event.dart';
part 'search_schedule_state.dart';

class SearchScheduleBloc
    extends Bloc<SearchScheduleEvent, SearchScheduleState> {
  final Parser _parser;

  SearchScheduleBloc(Parser parser)
      : _parser = parser,
        super(SearchScheduleInitial()) {
    on<LoadSearchingSchedule>(_loadSearchingSchedule);
  }

  Future<void> _loadSearchingSchedule(
      LoadSearchingSchedule event, Emitter<SearchScheduleState> emit) async {
    emit(SearchScheduleLoading(appBarName: event.scheduleName));

    try {
      final scheduleModel = await _parser.scheduleModel(
        link1: event.link1,
        link2: event.link2,
        scheduleName: event.scheduleName,
        scheduleType: event.scheduleType,
        isZo: event.link1.contains('zo'),
      );

      emit(SearchScheduleLoaded(
        scheduleModel: scheduleModel,
        appBarName: event.scheduleName,
      ));
    } on CustomException catch (e) {
      emit(SearchScheduleError(e.message));
    } catch (e) {
      emit(SearchScheduleError('Ошибка: ${e.runtimeType}'));
    }
  }
}
