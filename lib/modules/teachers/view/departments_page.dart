import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:schedule/core/view/schedule_tab.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';

class DepartmentsPage extends StatefulWidget {
  final CurrentFacultyState facultyState;

  const DepartmentsPage({
    super.key,
    required this.facultyState
  });

  @override
  State<StatefulWidget> createState() => _DepartmentsState();
}

class _DepartmentsState extends State<DepartmentsPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => Modular.get<FacultyBloc>()),
          BlocProvider(
              create: (context) => Modular.get<DepartmentBloc>()
                ..add(LoadDepartment(
                  departmentName:
                      widget.facultyState.departmentsMap.keys.elementAt(0),
                  link1:
                      widget.facultyState.departmentsMap.values.elementAt(0)[0],
                  link2: widget.facultyState.departmentsMap.values
                              .elementAt(0)
                              .length >
                          1
                      ? widget.facultyState.departmentsMap.values
                          .elementAt(0)[1]
                      : null,
                ))),
          BlocProvider(create: (context) => Modular.get<FavoriteButtonBloc>()),
        ],
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(title: _appBarText(context)),
            body: _body(context),
            drawer: _drawer(context),
            bottomNavigationBar: _bottomNavigation(context),
            floatingActionButton: _floatingActionButton(context),
          ),
        ));
  }

  Widget _appBarText(BuildContext context) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        if (state is DepartmentLoaded) {
          return Text(state.departmentName);
        }

        final facultyState = BlocProvider.of<FacultyBloc>(context).state;
        return Text(facultyState is CurrentFacultyState
            ? facultyState.facultyName
            : 'Преподаватели');
      },
    );
  }

  Widget _body(BuildContext context) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        if (state is DepartmentLoading || state is DepartmentInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DepartmentLoaded) {
          Modular.get<FavoriteButtonBloc>().add(CheckSchedule(
            scheduleType: ScheduleType.teacher,
            name: state.currentTeacher,
          ));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Text(
                      'Преподаватель:   ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: state.currentTeacher,
                        items: state.teachersScheduleMap.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          Modular.get<DepartmentBloc>()
                              .add(ChooseTeacher(teacherName: value));

                          //Modular.get<FavoriteBloc>().add(CheckSchedule(name: value));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(children: [
                  ScheduleTab(
                    tabNum: 0,
                    scheduleName: state.currentTeacher,
                    scheduleList:
                        state.teachersScheduleMap[state.currentTeacher]!,
                  ),
                  ScheduleTab(
                    tabNum: 1,
                    scheduleName: state.currentTeacher,
                    scheduleList:
                        state.teachersScheduleMap[state.currentTeacher]!,
                  ),
                ]),
              ),
            ],
          );
        }

        if (state is DepartmentError) {
          return Center(child: Text(state.message));
        }

        return const Center(child: Text('Неизвестная ошибка'));
      },
    );
  }

  Widget _drawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: SafeArea(
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      widget.facultyState.facultyName,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    )),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                    child: Text(
                      'Кафедры',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    children: List<ListTile>.generate(
                      widget.facultyState.departmentsMap.length,
                      (index) => ListTile(
                        title: Text(widget.facultyState.departmentsMap.keys
                            .elementAt(index)),
                        onTap: () {
                          final department = widget
                              .facultyState.departmentsMap.keys
                              .elementAt(index);
                          Modular.get<DepartmentBloc>().add(LoadDepartment(
                            departmentName: department,
                            link1: widget
                                .facultyState.departmentsMap[department]![0],
                            link2: widget
                                .facultyState.departmentsMap[department]![1],
                          ));

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return BlocListener<FavoriteButtonBloc, FavoriteButtonState>(
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

        if (state is FavoriteDoesNotExist && state.isNeedSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Удалено из избранного'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
      },
      child: BlocBuilder<DepartmentBloc, DepartmentState>(
        builder: (context, departmentState) {
          return BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
            builder: (context, state) {
              return FloatingActionButton(
                onPressed: departmentState is DepartmentLoaded
                    ? () {
                        if (state is FavoriteExist) {
                          Modular.get<FavoriteButtonBloc>().add(DeleteSchedule(
                              name: departmentState.currentTeacher,
                              scheduleType: ScheduleType.teacher));
                          return;
                        }

                        if (state is FavoriteDoesNotExist) {
                          Modular.get<FavoriteButtonBloc>().add(SaveSchedule(
                            name: departmentState.currentTeacher,
                            scheduleType: ScheduleType.teacher,
                            scheduleList: departmentState.teachersScheduleMap[
                                departmentState.currentTeacher]!,
                            link1: departmentState.link1,
                            link2: departmentState.link2,
                          ));
                        }
                      }
                    : null,
                child: state is FavoriteExist
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_border),
              );
            },
          );
        },
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        if (state is DepartmentLoaded) {
          return TabBar(
            tabs: List.generate(
              2,
              (index) {
                final star = index == state.weekNumber ? ' ★' : '';
                return Tab(
                  child: Text(
                    '${index + 1} неделя$star',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            labelColor: Colors.black87,
            labelStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          );
        }

        return const SizedBox();
      },
    );
  }
}
