import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:schedule/core/settings_types.dart';
import 'package:schedule/core/view/schedule_tab.dart';
import 'package:schedule/modules/classrooms/bloc/classrooms_bloc.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';

class ClassroomsPage extends StatefulWidget {
  const ClassroomsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassroomState();
}

class _ClassroomState extends State<ClassroomsPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: Modular.get<ClassroomsBloc>()),
        BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
      ],
      child: BlocBuilder<ClassroomsBloc, ClassroomsState>(
        builder: (context, state) {
          if (state is ClassroomsLoadedState) {
            Modular.get<FavoriteButtonBloc>().add(CheckSchedule(
              scheduleType: ScheduleType.classroom,
              name: state.currentClassroom,
            ));

            return DefaultTabController(
              length: 2,
              initialIndex: state.weekNumber,
              child: Scaffold(
                appBar: AppBar(title: _appBarText(state)),
                body: Column(
                  children: [
                    _dropDownButton(state, context),
                    Expanded(
                      child: TabBarView(children: [
                        ScheduleTab(
                            tabNum: 0,
                            scheduleName: state.currentClassroom,
                            scheduleList:
                                state.scheduleMap[state.currentBuildingName]![
                                    state.currentClassroom]!),
                        ScheduleTab(
                            tabNum: 1,
                            scheduleName: state.currentClassroom,
                            scheduleList:
                                state.scheduleMap[state.currentBuildingName]![
                                    state.currentClassroom]!),
                      ]),
                    ),
                  ],
                ),
                drawer: Drawer(
                  child: _drawer(state, context),
                ),
                bottomNavigationBar: TabBar(
                  tabs: List.generate(
                    2,
                    (index) {
                      final star = index == state.weekNumber ? ' ★' : '';
                      return Tab(
                        child: Text(
                          '${index + 1} неделя$star',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  labelStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                floatingActionButton: _floatingActionButton(),
              ),
            );
          }

          if (state is ClassroomsErrorState) {
            return Scaffold(
              appBar: AppBar(title: const Text('Ошибка')),
              body: Center(child: Text(state.message)),
            );
          }

          if (state is ClassroomsLoadingState) {
            return Scaffold(
              appBar: AppBar(title: const Text('Аудитории')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 15),
                    if(state.percents > 0) Text('${state.percents}%'),
                    Text(state.message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Ошибка')),
            body: const Center(child: Text('Неизвестная ошибка')),
          );
        },
      ),
    );
  }

  Widget _dropDownButton(ClassroomsLoadedState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text(
            'Аудитория:   ',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: state.currentClassroom,
              items: state.scheduleMap[state.currentBuildingName]!.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                Modular.get<ClassroomsBloc>().add(ChangeClassroom(value));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawer(ClassroomsLoadedState state, BuildContext context) {
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
                      'Расписание\nаудиторий',
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: Text(
                    'Корпуса',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: List<ListTile>.generate(
                    state.scheduleMap.length,
                    (index) => ListTile(
                      title: Text(state.scheduleMap.keys.elementAt(index)),
                      onTap: () {
                        final building =
                            state.scheduleMap.keys.elementAt(index);
                        final classroom =
                            state.scheduleMap[building]!.keys.first;
                        Modular.get<ClassroomsBloc>().add(
                            ChangeBuilding(building, classroom: classroom));
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
    );
  }

  Widget _appBarText(ClassroomsState state) {
    if (state is ClassroomsLoadedState) {
      return Text(state.currentBuildingName);
    }

    return const Text('Аудитории');
  }

  Widget _floatingActionButton() {
    return BlocListener<FavoriteButtonBloc, FavoriteButtonState>(
      listener: (context, state) {
        if (state is FavoriteExist && state.isNeedSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Добавлено в избранное'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        if (state is FavoriteDoesNotExist && state.isNeedSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Удалено из избранного'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
      },
      child: BlocBuilder<ClassroomsBloc, ClassroomsState>(
        builder: (context, classroomState) {
          return BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
            builder: (context, state) {
              return FloatingActionButton(
                onPressed: classroomState is ClassroomsLoadedState
                    ? () {
                        if (state is FavoriteExist) {
                          Modular.get<FavoriteButtonBloc>().add(DeleteSchedule(
                              name: classroomState.currentClassroom,
                              scheduleType: ScheduleType.classroom));
                          return;
                        }

                        if (state is FavoriteDoesNotExist) {
                          Modular.get<FavoriteButtonBloc>().add(SaveSchedule(
                            name: classroomState.currentClassroom,
                            scheduleType: ScheduleType.classroom,
                            scheduleList: classroomState.scheduleMap[
                                    classroomState.currentBuildingName]![
                                classroomState.currentClassroom]!,
                          ));

                          _noUpdateDialog();
                        }
                      }
                    : null,
                child: state is FavoriteExist
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_border),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _noUpdateDialog() async {
    final state = BlocProvider.of<SettingsBloc>(context).state;
    if (state is SettingsLoaded && !state.noUpdateClassroom) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Внимание'),
            content: const Text(
                'Расписание аудиторий не имеет возможности обновления из избранного'),
            actions: [
              TextButton(
                  onPressed: () {
                    BlocProvider.of<SettingsBloc>(context).add(ChangeSetting(
                        settingType: SettingsTypes.noUpdateClassroom,
                        value: 'true'));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Больше не показывать')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ок')),
            ],
          );
        },
      );
    }
  }
}
