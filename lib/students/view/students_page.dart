import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule/students/view/students_navigation.dart';
import 'package:schedule/students/view/students_view.dart';

import '../all_groups_bloc/all_groups_cubit.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllGroupsCubit, AllGroupsState>(
      builder: (context, state) {
        if (state is AllGroupsLoading) {
          BlocProvider.of<AllGroupsCubit>(context).loadGroupList();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
                state is CourseSelected ? state.courseName : 'Учебная группа'),
            leading: state is AllGroupsLoading || state is AllGroupsError
                ? null
                : Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu),
                      );
                    },
                  ),
          ),
          body: state is AllGroupsLoading
              ? const Center(child: CircularProgressIndicator())
              : state is AllGroupsError
                  ? const Center(child: Text('Ошибка загрузки'))
                  : state is AllGroupsLoaded
                      ? const Center(child: Text('Выберите курс'))
                      : StudentsView(),
          drawer: const Drawer(
            child: StudentsNavigation(),
          ),
        );
      },
    );
  }
}
