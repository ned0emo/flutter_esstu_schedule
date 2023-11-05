import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/view/schedule_page_body.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/students/all_groups_bloc/all_groups_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_bloc.dart';
import 'package:schedule/modules/students/views/students_drawer.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
            value: Modular.get<AllGroupsBloc>()..add(LoadAllGroups())),
        BlocProvider.value(value: Modular.get<CurrentGroupBloc>()),
        BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AllGroupsBloc, AllGroupsState>(
            listener: (context, state) {
              if (state is AllGroupsLoaded && state.warningMessage == null) {
                Modular.get<CurrentGroupBloc>().add(LoadGroup(
                    scheduleName: state.currentGroup,
                    link: state.currentCourseMap[state.currentGroup]!));
              }
            },
          ),
          BlocListener<CurrentGroupBloc, CurrentGroupState>(
            listener: (context, state) {
              if (state is CurrentGroupLoaded && state.message != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Внимание'),
                      content: Text(state.message!),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('ОК'))
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AllGroupsBloc, AllGroupsState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  state.appBarTitle ?? 'Учебные группы',
                  textAlign: TextAlign.left,
                ),
              ),
              body: Builder(
                builder: (context) {
                  if (state is AllGroupsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AllGroupsLoaded) {
                    return Column(
                      children: [
                        _dropDownButton(state),
                        Expanded(child: _body()),
                      ],
                    );
                  }

                  if (state is AllGroupsError) {
                    return Center(child: Text(state.errorMessage));
                  }

                  return const Center(child: Text('Неизвестная ошибка...'));
                },
              ),
              drawer: state is AllGroupsLoaded
                  ? Drawer(child: StudentsDrawer(state: state))
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _body() {
    return BlocBuilder<CurrentGroupBloc, CurrentGroupState>(
        builder: (context, state) {
      if (state is CurrentGroupInitial || state is CurrentGroupLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state is CurrentGroupLoaded) {
        return const SchedulePageBody<CurrentGroupBloc>();
      }

      if (state is CurrentGroupError) {
        return Center(
          child: Text(state.message, textAlign: TextAlign.center),
        );
      }

      return const Center(child: Text('Неизвестная ошибка...'));
    });
  }

  Widget _dropDownButton(AllGroupsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text('Группа:   ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: state.currentGroup,
              items: state.currentCourseMap.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                Modular.get<AllGroupsBloc>().add(SelectGroup(groupName: value));
                //Modular.get<FavoriteButtonBloc>().add(CheckSchedule(
                //  name: value,
                //  scheduleType: ScheduleType.student,
                //));
              },
            ),
          ),
        ],
      ),
    );
  }
}
