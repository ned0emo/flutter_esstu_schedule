import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../all_groups_bloc/all_groups_cubit.dart';

class StudentsNavigation extends StatelessWidget {
  const StudentsNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('meow'),
        ),
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
        const BakDrawerElement(course: '1 курс'),
        const BakDrawerElement(course: '2 курс'),
        const BakDrawerElement(course: '3 курс'),
        const BakDrawerElement(course: '4 курс'),
        const BakDrawerElement(course: '5 курс'),
        const BakDrawerElement(course: '6 курс'),
        const Divider(),
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
        const MagDrawerElement(course: '1 курс'),
        const MagDrawerElement(course: '2 курс'),
        const MagDrawerElement(course: '3 курс'),
        const MagDrawerElement(course: '4 курс'),
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
        const MagDrawerElement(course: '1 курс', isMag: true),
        const MagDrawerElement(course: '2 курс', isMag: true),
        const Divider(),
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
        const ZoDrawerElement(course: '1 курс'),
        const ZoDrawerElement(course: '2 курс'),
        const ZoDrawerElement(course: '3 курс'),
        const ZoDrawerElement(course: '4 курс'),
        const ZoDrawerElement(course: '5 курс'),
        const ZoDrawerElement(course: '6 курс'),
      ],
    );
  }
}

class BakDrawerElement extends StatelessWidget {
  final firstPartOfLink = '/bakalavriat/';
  final String course;

  const BakDrawerElement({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(course),
      onTap: () {
        BlocProvider.of<AllGroupsCubit>(context).selectCourse(course, 0, firstPartOfLink);
        Navigator.pop(context);
      },
    );
  }
}

class MagDrawerElement extends StatelessWidget {
  final firstPartOfLink = '/spezialitet/';
  final String course;
  final bool isMag;

  const MagDrawerElement({super.key, required this.course, this.isMag = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(course),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

class ZoDrawerElement extends StatelessWidget {
  final firstPartOfLink1 = '/zo1/';
  final firstPartOfLink2 = '/zo2/';
  final String course;

  const ZoDrawerElement({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(course),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
