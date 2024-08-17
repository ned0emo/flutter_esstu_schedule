import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/view/schedule_page_body.dart';
import 'package:schedule/modules/classrooms/bloc/classrooms_bloc.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';

class ClassroomsPage extends StatelessWidget {
  const ClassroomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(
              value: Modular.get<ClassroomsBloc>()
                ..add(LoadClassroomsSchedule())),
          BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
        ],
        child: BlocBuilder<ClassroomsBloc, ClassroomsState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: _appBarText(state)),
              body: _body(state),
              drawer: _drawer(state, context),
            );
          },
        ));
  }

  Widget _body(ClassroomsState state) {
    if (state is ClassroomsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ClassroomsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 15),
            Text('${state.percents}%'),
            Text(state.message, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (state is ClassroomsLoaded) {
      return Column(
        children: [
          _dropDownButton(state),
          Expanded(
              child: SchedulePageBody(
            scheduleModel: state.scheduleModel,
          )),
        ],
      );
    }

    if (state is ClassroomsError) {
      return Center(
        child: Text(state.message, textAlign: TextAlign.center),
      );
    }

    return const Center(child: Text('Неизвестная ошибка...'));
  }

  Widget? _drawer(ClassroomsState state, BuildContext context) {
    if (state is ClassroomsLoaded) {
      return Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Учебные корпуса',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              ...List.generate(
                state.scheduleMap.length,
                (index) {
                  final handlingBuildingName =
                      state.scheduleMap.keys.elementAt(index);
                  return state.currentBuildingName == handlingBuildingName
                      ? FilledButton(
                          style: const ButtonStyle(
                              alignment: AlignmentDirectional.centerStart),
                          child: Text(handlingBuildingName),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      : OutlinedButton(
                          style: const ButtonStyle(
                            alignment: AlignmentDirectional.centerStart,
                            side: WidgetStatePropertyAll(
                              BorderSide(color: Colors.transparent),
                            ),
                          ),
                          child: Text(handlingBuildingName),
                          onPressed: () {
                            Modular.get<ClassroomsBloc>()
                                .add(ChangeBuilding(handlingBuildingName));
                            Navigator.pop(context);
                          },
                        );
                },
              ),
            ],
          ),
        ),
      );
    }
    return null;
  }

  Widget _appBarText(ClassroomsState state) {
    return Text(state.appBarTitle ?? 'Аудитории', maxLines: 2);
  }

  Widget _dropDownButton(ClassroomsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text('Аудитория:   ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: state.currentClassroomName,
              items: state.scheduleMap[state.currentBuildingName]!
                  .map<DropdownMenuItem<String>>((ScheduleModel value) {
                return DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                Modular.get<ClassroomsBloc>().add(ChangeClassroom(
                  classroom: value,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
