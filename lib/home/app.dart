import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule/home/view/home_page.dart';
import 'package:schedule/settings/view/settings_page.dart';
import 'package:schedule/students/current_group_bloc/current_group_cubit.dart';
import 'package:schedule/students/current_group_bloc/current_group_repository.dart';
import 'package:schedule/students/view/students_page.dart';

import '../students/all_groups_bloc/all_groups_cubit.dart';
import '../students/all_groups_bloc/all_groups_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => CurrentGroupRepository()),
        RepositoryProvider(create: (context) => AllGroupsRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CurrentGroupCubit(
                repository:
                    RepositoryProvider.of<CurrentGroupRepository>(context)),
          ),
          BlocProvider(
            create: (context) => AllGroupsCubit(
                repository:
                    RepositoryProvider.of<AllGroupsRepository>(context)),
          ),
        ],
        child: MaterialApp(
          title: 'Расписание ВСГУТУ',
          theme: ThemeData(
            applyElevationOverlayColor: true,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006C84),
              secondary: Color(0xFF6EB5C0),
            ),
            scaffoldBackgroundColor: const Color(0xFFE2E8E4),
          ),
          home: const StudentsPage(),
        ),
      ),
    );
  }
}
