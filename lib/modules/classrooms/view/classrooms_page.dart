import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
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
            if (state.percents > 0) Text('${state.percents}%'),
            Text(state.message, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (state is ClassroomsLoaded) {
      return const SchedulePageBody<ClassroomsBloc>();
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
        child: Column(
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
                                state.scheduleMap[building]!.first.name;
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
        ),
      );
    }
    return null;
  }

  Widget _appBarText(ClassroomsState state) {
    return Text(state.appBarTitle ?? 'Аудитории', maxLines: 2);
  }
}
