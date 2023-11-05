import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/students_type.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_bloc.dart';

class StudentsDrawer extends StatelessWidget {
  final AllGroupsLoaded state;

  const StudentsDrawer({super.key, required this.state});

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
                _studTypeSection(
                    context, StudentsType.bak, state.bakScheduleMap),
                _studTypeSection(
                    context, StudentsType.col, state.colScheduleMap),
                _studTypeSection(
                    context, StudentsType.mag, state.magScheduleMap),
                _studTypeSection(
                    context, StudentsType.zo1, state.zoScheduleMap),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _studTypeSection(
    BuildContext context,
    String studType,
    Map<String, Map<String, String>> studScheduleMap,
  ) {
    final courseCount = studScheduleMap.keys
        .where((element) => studScheduleMap[element]?.isNotEmpty ?? false)
        .length;
    if (courseCount < 1) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: Text(
            _studTypeRussian(studType),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: List<ListTile>.generate(
            courseCount,
            (index) => ListTile(
              title: Text(
                studScheduleMap.keys.elementAt(index),
              ),
              onTap: () {
                Modular.get<AllGroupsBloc>().add(SelectCourse(
                    courseName: studScheduleMap.keys.elementAt(index),
                    studType: studType));
                Navigator.pop(context);
              },
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  String _studTypeRussian(String courseType) {
    switch (courseType) {
      case (StudentsType.bak):
        return 'Бакалавриат';
      case (StudentsType.col):
        return 'Колледж';
      case (StudentsType.mag):
        return 'Магистратура';
      default:
        return 'Заочное';
    }
  }
}
