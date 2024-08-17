import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/students_type.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_bloc.dart';

class StudentsDrawer extends StatelessWidget {
  final AllGroupsLoaded state;

  const StudentsDrawer({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: ListView(
        children: [
          _studTypeSection(context, StudentsType.bak,
              state.scheduleLinksMap[StudentsType.bak] ?? {}),
          _studTypeSection(context, StudentsType.col,
              state.scheduleLinksMap[StudentsType.col] ?? {}),
          _studTypeSection(context, StudentsType.mag,
              state.scheduleLinksMap[StudentsType.mag] ?? {}),
          _studTypeSection(context, StudentsType.zo1,
              state.scheduleLinksMap[StudentsType.zo1] ?? {}),
        ],
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              _studTypeRussian(studType),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...List.generate(
            courseCount,
            (index) {
              final isCurrentCourse = state.currentCourse ==
                      studScheduleMap.keys.elementAt(index) &&
                  state.studType == studType;
              return SizedBox(
                width: double.infinity,
                child: isCurrentCourse
                    ? FilledButton(
                        style: const ButtonStyle(
                            alignment: AlignmentDirectional.centerStart),
                        child: Text(studScheduleMap.keys.elementAt(index)),
                        onPressed: () => Navigator.pop(context),
                      )
                    : OutlinedButton(
                        style: const ButtonStyle(
                          alignment: AlignmentDirectional.centerStart,
                          side: WidgetStatePropertyAll(
                            BorderSide(color: Colors.transparent),
                          ),
                        ),
                        child: Text(studScheduleMap.keys.elementAt(index)),
                        onPressed: () {
                          Modular.get<AllGroupsBloc>().add(SelectCourse(
                              courseName: studScheduleMap.keys.elementAt(index),
                              studType: studType));
                          Navigator.pop(context);
                        },
                      ),
              );
            },
          ),
          const Divider(),
        ],
      ),
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
