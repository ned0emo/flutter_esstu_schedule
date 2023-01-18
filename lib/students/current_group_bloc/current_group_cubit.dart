import 'package:bloc/bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/students/current_group_bloc/current_group_repository.dart';

part 'current_group_state.dart';

class CurrentGroupCubit extends Cubit<CurrentGroupState> {
  final CurrentGroupRepository repository;

  int currentLesson = -1;

  CurrentGroupCubit({required this.repository}) : super(CurrentGroupInitial());

  Future<void> hideSchedule() async {
    emit(CurrentGroupInitial());
  }

  Future<void> loadCurrentGroup(String fullLink) async {
    emit(CurrentGroupLoading());

    final currentTime = Jiffy().dateTime.minute + Jiffy().dateTime.hour * 60;
    if (currentTime >= 540 && currentTime <= 635) {
      currentLesson = 0;
    } else if (currentTime >= 645 && currentTime <= 740) {
      currentLesson = 1;
    } else if (currentTime >= 780 && currentTime <= 875) {
      currentLesson = 2;
    } else if (currentTime >= 885 && currentTime <= 980) {
      currentLesson = 3;
    } else if (currentTime >= 985 && currentTime <= 1080) {
      currentLesson = 4;
    } else if (currentTime >= 1085 && currentTime <= 1180) {
      currentLesson = 5;
    }

    try {
      ///Для заочников 7 пар, для остальных - 6. На сайте прописано 8 пар,
      ///потому одну пару всегда надо скипать
      bool isZo = false;
      if (fullLink.contains('zo')) {
        isZo = true;
      }

      final groupSchedulePage =
          (await repository.loadCurrentGroupSchedulePage(fullLink))
              .replaceAll(' COLOR="#0000ff"', '');

      final List<List<String>> currentScheduleList = [];

      if (isZo) {
        final daysOfWeekList = [
          'Понедельник',
          'Вторник',
          'Среда',
          'Четверг',
          'Пятница',
          'Суббота',
          'Воскресенье',
        ];

        final List<String> splittedPage = groupSchedulePage
            .split('<FONT FACE="Arial" SIZE=1><P ALIGN="CENTER">');

        const numOfLessons = 8;

        for (int i = 0, k = 0; i + 7 < splittedPage.length; i += 8, k++) {
          final List<String> dayScheduleList = [];

          try {
            final currentDayOfWeekStrSplit =
                splittedPage[i].split('SIZE=2><P ALIGN="CENTER">');
            if (currentDayOfWeekStrSplit.length > 1) {
              dayScheduleList.add(currentDayOfWeekStrSplit[1]
                  .substring(0, currentDayOfWeekStrSplit[1].indexOf('</B>')));
            } else {
              dayScheduleList.add(daysOfWeekList[k%7]);
            }
          } catch (_) {
            dayScheduleList.add('Ошибка определения дня недели лол');
          }

          for (int j = i + 1; j < i + numOfLessons; j++) {
            dayScheduleList.add(
                splittedPage[j].substring(0, splittedPage[j].indexOf('<')));
          }

          currentScheduleList.add(dayScheduleList);
        }
      } else {
        final List<String> splittedPage = groupSchedulePage
            .split('<FONT FACE="Arial" SIZE=1><P ALIGN="CENTER">')
            .skip(1)
            .toList();

        const numOfLessons = 6;

        for (int i = 0; i + 7 < splittedPage.length; i += 8) {
          final List<String> dayScheduleList = [];

          for (int j = i; j < i + numOfLessons; j++) {
            dayScheduleList.add(
                splittedPage[j].substring(0, splittedPage[j].indexOf('<')));
          }

          currentScheduleList.add(dayScheduleList);
        }
      }

      emit(
        CurrentGroupLoaded(
            currentScheduleList: currentScheduleList,
            scheduleFullLink: fullLink,
            openedDayIndex: Jiffy().dateTime.weekday - 1,
            currentLesson: currentLesson),
      );
    } catch (exception) {
      emit(CurrentGroupLoadingError());
    }
  }

  Future<void> changeOpenedDay(int index) async {
    final currentState = state;
    if (currentState is CurrentGroupLoaded) {
      emit(
        CurrentGroupLoaded(
            currentScheduleList: currentState.currentScheduleList,
            scheduleFullLink: currentState.scheduleFullLink,
            openedDayIndex: index,
            currentLesson: currentLesson),
      );
    }
  }

  Future<bool> addScheduleToFavorite(String name) async {
    final currentState = state;
    if (currentState is CurrentGroupLoaded) {
      try {
        String scheduleData = currentState.scheduleFullLink;
        for (List<String> list in currentState.currentScheduleList) {
          scheduleData += '\n;;;';
          for (String lesson in list) {
            scheduleData += '\n$lesson';
          }
        }

        await repository.saveSchedule(name, scheduleData);
      } catch (_) {
        return false;
      }
    }

    return true;
  }
}
