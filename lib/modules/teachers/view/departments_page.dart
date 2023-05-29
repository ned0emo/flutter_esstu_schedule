import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';
import 'package:schedule/modules/teachers/view/department_schedule_tab.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<StatefulWidget> createState() => _DepartmentsState();
}

class _DepartmentsState extends State<DepartmentsPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => Modular.get<FacultyBloc>()),
        BlocProvider(create: (context) => Modular.get<DepartmentBloc>()),
      ],
      child: BlocBuilder<FacultyBloc, FacultyState>(
        builder: (context, state) {
          if (state is CurrentFacultyState) {
            BlocProvider.of<DepartmentBloc>(context).add(LoadDepartment(
                departmentName: state.departmentsMap.keys.elementAt(0),
                link1: state
                    .departmentsMap[state.departmentsMap.keys.elementAt(0)]![0],
                link2: state.departmentsMap[
                    state.departmentsMap.keys.elementAt(0)]![1]));
            return DefaultTabController(
              length: 2,
              initialIndex: state.weekNumber,
              child: Scaffold(
                appBar:
                    AppBar(title: _appBarText(state.abbreviatedFacultyName)),
                body: Column(
                  children: [
                    _dropDownButton(),
                    const Expanded(
                      child: TabBarView(children: [
                        DepartmentScheduleTab(tabNum: 0),
                        DepartmentScheduleTab(tabNum: 1),
                      ]),
                    ),
                  ],
                ),
                drawer: Drawer(
                  child: _drawer(state, context),
                ),
                bottomNavigationBar: TabBar(
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
                  labelStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }

          if (state is FacultiesErrorState) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Неизвестная ошибка'));
        },
      ),
    );
  }

  Widget _dropDownButton() {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        if (state is DepartmentLoaded) {
          return Padding(
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
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _drawer(CurrentFacultyState facultyState, BuildContext context) {
    return Column(
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
                    facultyState.facultyName,
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
                    facultyState.departmentsMap.length,
                    (index) => ListTile(
                      title: Text(
                          facultyState.departmentsMap.keys.elementAt(index)),
                      onTap: () {
                        final department =
                            facultyState.departmentsMap.keys.elementAt(index);
                        BlocProvider.of<DepartmentBloc>(context)
                            .add(LoadDepartment(
                          departmentName: department,
                          link1: facultyState.departmentsMap[department]![0],
                          link2: facultyState.departmentsMap[department]![1],
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
    );
  }

  Widget _appBarText(String facultyName) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        if (state is DepartmentLoaded) {
          return Text(state.departmentName);
        }

        return Text(facultyName);
      },
    );
  }
}
