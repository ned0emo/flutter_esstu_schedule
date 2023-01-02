import 'package:bloc/bloc.dart';
import 'package:schedule/students/current_group_bloc/current_group_repository.dart';

part 'current_group_state.dart';

class CurrentGroupCubit extends Cubit<CurrentGroupState> {
  final CurrentGroupRepository repository;

  ///Для заочников 7 пар, для остальных - 6. На сайте прописано 8 пар,
  ///потому одну пару всегда надо скипать
  bool isZo = false;

  CurrentGroupCubit({required this.repository}) : super(CurrentGroupInitial());

  Future<void> loadCurrentGroup(String fullLink) async {
    emit(CurrentGroupLoading());

    try {
      final groupSchedulePage =
          (await repository.loadCurrentGroupSchedulePage(fullLink))
              .replaceAll(' COLOR="#0000ff"', '');

      final List<List<String>> currentScheduleList = [];

      final List<String> splittedPage = groupSchedulePage
          .split('<FONT FACE="Arial" SIZE=1><P ALIGN="CENTER">')
          .skip(1)
          .toList();

      final numOfLessons = isZo ? 7 : 6;

      for (int i = 0; i + 7 < splittedPage.length; i += 8) {
        final List<String> dayScheduleList = [];

        for (int j = i; j < i + numOfLessons; j++) {
          dayScheduleList
              .add(splittedPage[j].substring(0, splittedPage[j].indexOf('<')));
        }

        currentScheduleList.add(dayScheduleList);
      }

      emit(
        CurrentGroupLoaded(
          currentScheduleList: currentScheduleList,
          scheduleFullLink: fullLink,
        ),
      );
    } catch (exception) {
      emit(CurrentGroupLoadingError());
    }
  }
}
