import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:schedule/core/time/week_number_repository.dart';

part 'week_number_event.dart';

part 'week_number_state.dart';

class WeekNumberBloc extends Bloc<WeekNumberEvent, WeekNumberState> {
  final WeekNumberRepository _repository;

  WeekNumberBloc(this._repository) : super(WeekNumberLoading()) {
    on<CheckWeekNumber>((event, emit) async {
      emit(WeekNumberLoading());
      try {
        await _repository.setWeekShifting();
        emit(WeekNumberLoaded());
      } catch (e) {
        emit(WeekNumberError());
      }
    });
  }
}
