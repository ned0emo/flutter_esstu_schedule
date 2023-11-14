import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/view/schedule_page_body.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/teachers/departments_bloc/department_bloc.dart';
import 'package:schedule/modules/teachers/faculties_bloc/faculty_bloc.dart';

class DepartmentsPage extends StatelessWidget {
  final CurrentFacultyState facultyState;

  const DepartmentsPage({super.key, required this.facultyState});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: Modular.get<DepartmentBloc>()
              ..add(
                LoadDepartment(
                  departmentName: facultyState.firstDepartment,
                  link1: facultyState.firstLink1,
                  link2: facultyState.firstLink2,
                ),
              ),
          ),
          BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
        ],
        child: Scaffold(
          appBar: AppBar(title: _appBarText(context)),
          body: _body(context),
          drawer: _drawer(context),
        ));
  }

  Widget _appBarText(BuildContext context) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) =>
          Text(state.appBarTitle ?? 'Преподаватели', maxLines: 2),
    );
  }

  Widget _body(BuildContext context) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        if (state is DepartmentLoading || state is DepartmentInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DepartmentLoaded) {
          return Column(
            children: [
              _dropDownButton(state),
              const Expanded(child: SchedulePageBody<DepartmentBloc>()),
            ],
          );
        }

        if (state is DepartmentError) {
          if (state.errorMessage != null) {
            return Center(
              child: Text(state.errorMessage!, textAlign: TextAlign.center),
            );
          }
          if (state.warningMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/hmmm.png',
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                  Text(state.warningMessage!, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Неизвестная ошибка...', textAlign: TextAlign.center),
          );
        }

        return const Center(child: Text('Неизвестная ошибка...'));
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
                          Modular.get<DepartmentBloc>().add(LoadDepartment(
                            departmentName: department,
                            link1: facultyState.departmentsMap[department]![0],
                            link2: facultyState
                                        .departmentsMap[department]!.length >
                                    1
                                ? facultyState.departmentsMap[department]![1]
                                : null,
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

  Widget _dropDownButton(DepartmentLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text('Преподаватель:   ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: state.currentTeacherName,
              items: state.teachersScheduleData
                  .map<DropdownMenuItem<String>>((ScheduleModel value) {
                return DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                Modular.get<DepartmentBloc>().add(ChangeTeacher(
                  teacherName: value,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
