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
                  ? Center(
                      child: Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                    ))
                  : state is AllGroupsLoaded
                      ? Column(
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
                        )
                      : StudentsView(),
          drawer: const Drawer(
            child: StudentsNavigation(),
          ),
        );
      },
    );
  }
}
