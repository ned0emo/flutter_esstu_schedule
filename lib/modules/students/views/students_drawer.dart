import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_cubit.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_cubit.dart';

class StudentsDrawer extends StatelessWidget {
  const StudentsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.primary,
          child: const SafeArea(
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Расписание учебных групп',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _bakDrawerSection(context),
                _magDrawerSection(context),
                _zoDrawerSection(context),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _bakDrawerSection(BuildContext context) {
    const firstPartOfLink = '/bakalavriat/';

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Text(
            'Бакалавриат',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: List<ListTile>.generate(
            6,
            (index) => ListTile(
              title: Text('${index + 1} курс'),
              onTap: () {
                BlocProvider.of<CurrentGroupCubit>(context).hideSchedule();
                BlocProvider.of<AllGroupsCubit>(context)
                    .selectCourse('${index + 1} курс', 0, firstPartOfLink);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _magDrawerSection(BuildContext context) {
    const firstPartOfLink = '/spezialitet/';

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Text(
            'Колледж',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: List<ListTile>.generate(
            4,
            (index) => ListTile(
              title: Text('${index + 1} курс'),
              onTap: () {
                BlocProvider.of<CurrentGroupCubit>(context).hideSchedule();
                BlocProvider.of<AllGroupsCubit>(context)
                    .selectCourse('${index + 1} курс', 1, firstPartOfLink);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Text(
            'Магистратура',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: List<ListTile>.generate(
            2,
            (index) => ListTile(
              title: Text('${index + 1} курс'),
              onTap: () {
                BlocProvider.of<CurrentGroupCubit>(context).hideSchedule();
                BlocProvider.of<AllGroupsCubit>(context)
                    .selectCourse('${index + 1} курс', 2, firstPartOfLink);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _zoDrawerSection(BuildContext context) {
    const firstPartOfLink1 = '/zo1/';

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Text(
            'Заочное',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: List<ListTile>.generate(
            6,
            (index) => ListTile(
              title: Text('${index + 1} курс'),
              onTap: () {
                BlocProvider.of<CurrentGroupCubit>(context).hideSchedule();
                BlocProvider.of<AllGroupsCubit>(context).selectCourse(
                  '${index + 1} курс',
                  3,
                  firstPartOfLink1,
                  isZo: true,
                );
                Navigator.pop(context);
              },
            ),
          ),
        )
      ],
    );
  }
}
