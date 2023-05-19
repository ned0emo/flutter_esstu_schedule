import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/favorite/bloc/favorite_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_cubit.dart';
import 'package:schedule/modules/students/views/students_schedule_tab.dart';

class StudentsTabController extends StatefulWidget {
  const StudentsTabController({super.key});

  @override
  State<StatefulWidget> createState() => _StudentsTabControllerState();
}

class _StudentsTabControllerState extends State<StudentsTabController> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentGroupCubit, CurrentGroupState>(
      builder: (context, currentGroupState) {
        if (currentGroupState is CurrentGroupLoaded) {
          return DefaultTabController(
            length: currentGroupState.numOfWeeks,
            initialIndex: currentGroupState.initialIndex,
            child: Column(
              children: [
                Expanded(
                  child: Scaffold(
                    body: TabBarView(
                      children: List<StudentsScheduleTab>.generate(
                        currentGroupState.numOfWeeks,
                        (index) => StudentsScheduleTab(tabNum: index),
                      ),
                    ),
                    floatingActionButton:
                        BlocListener<FavoriteBloc, FavoriteState>(
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

                        if (state is FavoriteDoesNotExist &&
                            state.isNeedSnackBar) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Удалено из избранного'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                      },
                      child: BlocBuilder<FavoriteBloc, FavoriteState>(
                        builder: (context, state) {
                          return FloatingActionButton(
                            onPressed: () {
                              if (state is FavoriteExist) {
                                Modular.get<FavoriteBloc>().add(DeleteSchedule(
                                    name: currentGroupState.name));
                                return;
                              }

                              if (state is FavoriteDoesNotExist) {
                                Modular.get<FavoriteBloc>().add(SaveSchedule(
                                    name: currentGroupState.name,
                                    link1: currentGroupState.scheduleFullLink,
                                    scheduleList:
                                        currentGroupState.currentScheduleList));
                              }
                            },
                            child: state is FavoriteExist
                                ? const Icon(Icons.star)
                                : const Icon(Icons.star_border),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                TabBar(
                  tabs: List<Tab>.generate(
                    currentGroupState.numOfWeeks,
                    (index) {
                      final star =
                          index == currentGroupState.starIndex ? '★' : '';
                      return Tab(
                        child: Text(
                          '${index + 1} неделя $star',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  labelColor: Colors.black87,
                  labelStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        if (currentGroupState is CurrentGroupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (currentGroupState is CurrentGroupLoadingError) {
          return Center(
              child: Text('Ошибка загрузки\n${currentGroupState.message}'));
        }

        return const Text('Неизвестная ошибка');
      },
    );
  }
}
