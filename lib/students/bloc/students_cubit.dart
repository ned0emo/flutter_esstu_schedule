import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:schedule/students/bloc/students_repository.dart';
import 'package:tuple/tuple.dart';

part 'students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  final StudentsRepository repository;
  int loadCounter = 0;
  int errorCounter = 0;
  bool continueLoad = true;
  //final scheduleNames = ['bak', 'mag', 'zo1', 'zo2'];
  final bakScheduleMap = <String, List<Tuple2<String, String>>>{
    '1 курс': [],
    '2 курс': [],
    '3 курс': [],
    '4 курс': [],
    '5 курс': [],
    '6 курс': [],
  };
  final colScheduleMap = <String, List<Tuple2<String, String>>>{
    '1 курс': [],
    '2 курс': [],
    '3 курс': [],
    '4 курс': [],
  };
  final magScheduleMap = <String, List<Tuple2<String, String>>>{
    '1 курс': [],
    '2 курс': [],
  };
  final zo1ScheduleMap = <String, List<Tuple2<String, String>>>{
    '1 курс': [],
    '2 курс': [],
    '3 курс': [],
    '4 курс': [],
    '5 курс': [],
    '6 курс': [],
  };
  final zo2ScheduleMap = <String, List<Tuple2<String, String>>>{
    '1 курс': [],
    '2 курс': [],
    '3 курс': [],
    '4 курс': [],
    '5 курс': [],
    '6 курс': [],
  };

  StudentsCubit({required this.repository}) : super(StudentsLoading());

  Future<void> loadSchedule() async {
    final groupPagesList = await repository.loadGroupsPages();

    await createGroupLinkPairList(groupPagesList);
    
    while(loadCounter < 24 && errorCounter < 50){
      sleep(const Duration(microseconds: 100));
      errorCounter++;
    }
    if(errorCounter > 49){
      continueLoad = false;
    }
  }

  Future<void> createGroupLinkPairList(List<String> groupPageList) async {
    continueLoad = true;
    for (int i = 1; i < 7 && continueLoad; i++) {
      fillCourseSchedule(groupPageList[0], i, bakScheduleMap);
      fillCourseSchedule(groupPageList[2], i, zo1ScheduleMap);
      fillCourseSchedule(groupPageList[3], i, zo2ScheduleMap);
    }
    for (int i = 1; i < 5 && continueLoad; i++) {
      fillCourseSchedule(groupPageList[1], i, colScheduleMap);
    }
    for (int i = 1; i < 3 && continueLoad; i++) {
      fillCourseSchedule(groupPageList[1], i, magScheduleMap, courseFix: 4);
    }
  }

  Future<void> fillCourseSchedule(String pageText, int courseName,
      Map<String, List<Tuple2<String, String>>> scheduleMap, {int courseFix = 0}) async {
    final List<String> splittedPage = pageText.split('href="').skip(1).toList();

    for (int i = courseName - 1, emptinessCounter = 0;
        emptinessCounter < 3 && continueLoad;
        i += 6) {
      String link = splittedPage[i].substring(0, splittedPage[i].indexOf('">'));
      String group = splittedPage[i].substring(
          splittedPage[i].indexOf('Roman">') + 7,
          splittedPage[i].indexOf('</'));

      if (group.length < 3) {
        emptinessCounter++;
      } else {
        scheduleMap['${courseName - courseFix} курс']?.add(Tuple2(link, group));
      }
    }
    
    loadCounter++;
  }
}
