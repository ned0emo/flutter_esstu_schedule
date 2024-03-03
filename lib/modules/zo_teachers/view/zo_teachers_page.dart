import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/models/schedule_model.dart';
import 'package:schedule/core/view/schedule_page_body.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/zo_teachers/bloc/zo_teachers_bloc.dart';

class ZoTeachersPage extends StatelessWidget {
  const ZoTeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(
              value: Modular.get<ZoTeachersBloc>()
                ..add(LoadZoTeachersSchedule())),
          BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
        ],
        child: BlocBuilder<ZoTeachersBloc, ZoTeachersState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: _appBarText(state)),
              body: _body(state),
              drawer: _drawer(state, context),
            );
          },
        ));
  }

  Widget _body(ZoTeachersState state) {
    if (state is ZoTeachersInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ZoTeachersLoading) {
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

    if (state is ZoTeachersLoaded) {
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

    if (state is ZoTeachersError) {
      return Center(
        child: Text(state.message, textAlign: TextAlign.center),
      );
    }

    return const Center(child: Text('Неизвестная ошибка...'));
  }

  Widget? _drawer(ZoTeachersState state, BuildContext context) {
    if (state is ZoTeachersLoaded) {
      return Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Первая буква фамилии преподавателя',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              ...List.generate(
                state.scheduleMap.length,
                (index) {
                  final handlingLetter =
                      state.scheduleMap.keys.elementAt(index);
                  return state.currentBuildingName == handlingLetter
                      ? FilledButton(
                          style: const ButtonStyle(
                              alignment: AlignmentDirectional.centerStart),
                          child: Text(handlingLetter),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      : OutlinedButton(
                          style: const ButtonStyle(
                            alignment: AlignmentDirectional.centerStart,
                            side: MaterialStatePropertyAll(
                              BorderSide(color: Colors.transparent),
                            ),
                          ),
                          child: Text(handlingLetter),
                          onPressed: () {
                            Modular.get<ZoTeachersBloc>()
                                .add(ChangeZoLetter(handlingLetter));
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

  Widget _appBarText(ZoTeachersState state) {
    return Text(state.appBarTitle ?? 'Преподаватели', maxLines: 2);
  }

  Widget _dropDownButton(ZoTeachersLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text('Преподаватель:   ', style: TextStyle(fontSize: 18)),
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

                Modular.get<ZoTeachersBloc>().add(ChangeZoTeacher(
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
