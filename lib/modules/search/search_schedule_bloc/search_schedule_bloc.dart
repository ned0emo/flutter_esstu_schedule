import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

part 'search_schedule_event.dart';
part 'search_schedule_state.dart';

class SearchScheduleBloc extends Bloc<SearchScheduleEvent, SearchScheduleState> {
  SearchScheduleBloc() : super(SearchScheduleInitial()) {
    on<SearchScheduleEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
