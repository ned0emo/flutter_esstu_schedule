import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'classroom_state.dart';

class ClassroomCubit extends Cubit<ClassroomState> {
  ClassroomCubit() : super(ClassroomInitial());
}
