import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/time/week_number_repository.dart';

part 'week_number_event.dart';

part 'week_number_state.dart';

class WeekNumberBloc extends Bloc<WeekNumberEvent, WeekNumberState> {
  final WeekNumberRepository _repository;

  WeekNumberBloc(this._repository) : super(WeekNumberInitial()) {
    on<CheckWeekNumber>((event, emit) async {
      /// блокировка повторных запросов
      if (state is WeekNumberLoading) return;

      emit(WeekNumberLoading());
      try {
        emit(WeekNumberLoaded(
            weekShifting: await _repository.setWeekShifting()));
      } catch (e) {
        emit(WeekNumberError());
      }
    });
  }
}
