import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/classrooms/bloc/classrooms_bloc.dart';
import 'package:schedule/modules/classrooms/view/classrooms_schedule_tab.dart';

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
        BlocProvider(create: (context) => Modular.get<ClassroomsBloc>()),
      ],
      child: BlocBuilder<ClassroomsBloc, ClassroomsState>(
        builder: (context, state) {
          if (state is ClassroomsLoadedState) {
            return DefaultTabController(
              length: 2,
              initialIndex: state.weekNumber,
              child: Scaffold(
                appBar: AppBar(title: _appBarText(state)),
                body: Column(
                  children: [
                    _dropDownButton(state, context),
                    const Expanded(
                      child: TabBarView(children: [
                        ClassroomScheduleTab(tabNum: 0),
                        ClassroomScheduleTab(tabNum: 1),
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
                  labelColor: Colors.black87,
                  labelStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
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
                  Text('${state.percents}%'),
                ],
              )),
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

                BlocProvider.of<ClassroomsBloc>(context)
                    .add(ChangeClassroom(value));
                //Modular.get<FavoriteBloc>().add(CheckSchedule(name: value));
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
                        final classroom = state.scheduleMap[building]!.keys.first;
                        BlocProvider.of<ClassroomsBloc>(context)
                            .add(ChangeBuilding(building, classroom: classroom));
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
}
