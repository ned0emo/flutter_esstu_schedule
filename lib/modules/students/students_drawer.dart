import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'all_groups_bloc/all_groups_cubit.dart';
import 'current_group_bloc/current_group_cubit.dart';

class StudentsDrawer extends StatelessWidget {
  const StudentsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SafeArea(
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('meow'),
          ),
        ),
        _bakDrawerSection(context),
        _magDrawerSection(context),
        _zoDrawerSection(context),
      ],
    );
  }

  Widget _bakDrawerSection(BuildContext context) {
    const firstPartOfLink = '/bakalavriat/';

    return Column(
      children: [
        Container(
          height: 30,
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: const Text(
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
        Container(
          height: 30,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: const Text(
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
        Container(
          height: 30,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: const Text(
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
    const firstPartOfLink2 = '/zo2/';

    return Column(
      children: [
        Container(
          height: 30,
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: const Text(
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
                  typeLink2: firstPartOfLink2,
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
