import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'teachers_state.dart';

class TeachersCubit extends Cubit<TeachersState> {
  TeachersCubit() : super(TeachersInitial());
}
