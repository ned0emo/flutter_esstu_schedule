import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:schedule/core/view/schedule_tab.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_bloc.dart';
import 'package:schedule/modules/students/views/students_drawer.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
            value: Modular.get<AllGroupsBloc>()..add(LoadAllGroups())),
        BlocProvider.value(value: Modular.get<CurrentGroupBloc>()),
        BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
      ],
      child: BlocListener<AllGroupsBloc, AllGroupsState>(
        listener: (context, state) {
          if (state is AllGroupsLoaded && state.warningMessage == null) {
            Modular.get<CurrentGroupBloc>().add(LoadGroup(
                scheduleName: state.currentGroup,
                link: state.currentCourseMap[state.currentGroup]!));
            Modular.get<FavoriteButtonBloc>().add(CheckSchedule(
                scheduleType: ScheduleType.student, name: state.currentGroup));
          }
        },
        child: BlocBuilder<AllGroupsBloc, AllGroupsState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  state is CourseSelected ? state.courseName : 'Учебная группа',
                  textAlign: TextAlign.left,
                ),
              ),
              body: BlocBuilder<AllGroupsBloc, AllGroupsState>(
                builder: (context, state) {
                  if (state is AllGroupsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AllGroupsError) {
                    return Center(
                        child: Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                    ));
                  }

                  if (state is AllGroupsLoaded) {
                    return state.warningMessage != null
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/hmmm.png',
                                width: 180,
                                height: 180,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                state.warningMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ))
                        : Column(
                            children: [
                              _dropDownButton(state),
                              Expanded(child: _body()),
                            ],
                          );
                  }

                  return const Center(child: Text('Неизвестная ошибка'));
                },
              ),
              drawer: state is AllGroupsLoaded
                  ? const Drawer(child: StudentsDrawer())
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _dropDownButton(AllGroupsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text(
            'Группа:   ',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: state.currentGroup,
              items: state.currentCourseMap.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                Modular.get<AllGroupsBloc>().add(SelectGroup(groupName: value));
                Modular.get<FavoriteButtonBloc>().add(CheckSchedule(
                  name: value,
                  scheduleType: ScheduleType.student,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return BlocBuilder<CurrentGroupBloc, CurrentGroupState>(
      builder: (context, currentGroupState) {
        if (currentGroupState is CurrentGroupLoaded) {
          return DefaultTabController(
            length: currentGroupState.numOfWeeks,
            initialIndex: currentGroupState.weekNumber,
            child: Column(
              children: [
                Expanded(
                  child: Scaffold(
                    body: TabBarView(
                      children: List.generate(
                        currentGroupState.numOfWeeks,
                        (index) => ScheduleTab(
                          tabNum: index,
                          scheduleName: currentGroupState.name,
                          scheduleList: currentGroupState.scheduleList,
                          customDaysOfWeek: currentGroupState.daysOfWeekList,
                        ),
                      ),
                    ),
                    floatingActionButton:
                        BlocListener<FavoriteButtonBloc, FavoriteButtonState>(
                      listener: (context, state) {
                        if (state is FavoriteExist && state.isNeedSnackBar) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Добавлено в избранное'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }

                        if (state is FavoriteDoesNotExist &&
                            state.isNeedSnackBar) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Удалено из избранного'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                      },
                      child:
                          BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
                        builder: (context, state) {
                          return FloatingActionButton(
                            onPressed: () {
                              if (state is FavoriteExist) {
                                Modular.get<FavoriteButtonBloc>()
                                    .add(DeleteSchedule(
                                  name: currentGroupState.name,
                                  scheduleType: ScheduleType.student,
                                ));
                                return;
                              }

                              if (state is FavoriteDoesNotExist) {
                                Modular.get<FavoriteButtonBloc>()
                                    .add(SaveSchedule(
                                  name: currentGroupState.name,
                                  scheduleType: ScheduleType.student,
                                  scheduleList: currentGroupState.scheduleList,
                                  link1: currentGroupState.link,
                                  daysOfWeekList:
                                      currentGroupState.daysOfWeekList,
                                ));

                                _addToMainDialog(currentGroupState);
                              }
                            },
                            child: state is FavoriteExist
                                ? const Icon(Icons.star)
                                : const Icon(Icons.star_border),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                TabBar(
                  tabs: List<Tab>.generate(
                    currentGroupState.numOfWeeks,
                    (index) {
                      final star = !currentGroupState.isZo &&
                              index == currentGroupState.weekNumber
                          ? '★'
                          : '';
                      return Tab(
                        child: Text(
                          '${index + 1} неделя $star',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  labelStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        if (currentGroupState is CurrentGroupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (currentGroupState is CurrentGroupError) {
          return Center(
              child: Text(
            currentGroupState.message,
            textAlign: TextAlign.center,
          ));
        }

        return const Center(child: Text('Неизвестная ошибка'));
      },
    );
  }

  Future<void> _addToMainDialog(CurrentGroupLoaded state) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Открывать при запуске приложения?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Нет')),
            TextButton(
                onPressed: () {
                  Modular.get<FavoriteButtonBloc>().add(AddFavoriteToMainPage(
                    scheduleType: ScheduleType.student,
                    name: state.name,
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('Да')),
          ],
        );
      },
    );
  }
}
