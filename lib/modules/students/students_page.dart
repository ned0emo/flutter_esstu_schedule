import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_cubit.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_cubit.dart';
import 'package:schedule/modules/students/students_drawer.dart';
import 'package:schedule/modules/students/students_tab_controller.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => Modular.get<AllGroupsCubit>()),
        BlocProvider(create: (context) => Modular.get<CurrentGroupCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AllGroupsCubit, AllGroupsState>(
            builder: (context, state) {
              return Text(
                state is CourseSelected ? state.courseName : 'Учебная группа',
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
        body: BlocBuilder<AllGroupsCubit, AllGroupsState>(
          builder: (context, state) {
            return Column(
              children: [
                _dropDownButton(state),
                Expanded(child: _mainContent(state)),
              ],
            );
          },
        ),
        drawer: const Drawer(
          child: StudentsDrawer(),
        ),
      ),
    );
  }

  Widget _dropDownButton(AllGroupsState state) {
    if (state is CourseSelected) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Группа:',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: DropdownButton<String>(
              value: state.currentGroup,
              items: state.linkGroupMap.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),

              ///
              ///Выбор учебной группы
              ///
              ///TODO: П Е Р Е Д Е Л А Т Ь
              ///
              onChanged: (value) {
                Modular.get<AllGroupsCubit>().selectGroup(value ?? '');

                state.typeLink2 == ''
                    ? Modular.get<CurrentGroupCubit>().loadCurrentGroup(
                        state.typeLink1 + (state.linkGroupMap[value] ?? ''))
                    : Modular.get<CurrentGroupCubit>()
                        .loadCurrentGroup((state.linkGroupMap[value] ?? ''));
              },
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _mainContent(AllGroupsState state) {
    if (state is AllGroupsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AllGroupsError) {
      return Center(
        child: Text(
          state.errorMessage,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state is AllGroupsLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
            child: Image.asset(
              'assets/arrowToGroups.png',
              height: 60,
            ),
          ),
          const Text(
            '\t\tВыберите курс',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Container(),
          ),
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Добавить расписание в избранное',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: FloatingActionButton(
                  onPressed: null,
                  child: Icon(Icons.star_border),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const StudentsTabController();
  }
}
/*
class ZoScheduleTab extends Container {
  final int tabNum;

  ZoScheduleTab({super.key, required this.tabNum});

  @override
  Widget build(BuildContext context) {
    final currentState = BlocProvider.of<CurrentGroupCubit>(context).state;

    if (currentState is CurrentGroupInitial) {
      return Column(
        children: [
          Image.asset(
            'assets/arrowToGroups.png',
            height: 60,
          ),
          const Text(
            'Выберите группу',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      );
    }

    if (currentState is CurrentGroupLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentState is CurrentGroupLoaded) {
      final numOfDays = currentState.currentScheduleList.length == 12 ? 6 : 7;

      if (tabNum * numOfDays < currentState.currentScheduleList.length) {
        return ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: DayOfWeekCard(
                dayOfWeekIndex: index,
                scheduleList: currentState
                    .currentScheduleList[index + tabNum * numOfDays]
                    .skip(1)
                    .toList(),
                dayOfWeek: currentState
                    .currentScheduleList[index + tabNum * numOfDays][0],
              ),
            );
          },
          itemCount: numOfDays,
        );
      }

      return const Center(child: Text('На эту неделю отсутствует расписание'));
    }

    return const Center(child: Text('Ошибка загрузки'));
  }
}
*/
