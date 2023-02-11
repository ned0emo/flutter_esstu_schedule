import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule/modules/students/current_group_bloc/current_group_cubit.dart';
import 'package:schedule/modules/students/students_schedule_tab.dart';

class StudentsTabController extends StatelessWidget {
  const StudentsTabController({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentGroupCubit, CurrentGroupState>(
      builder: (context, state) {
        if (state is CurrentGroupLoaded) {
          return DefaultTabController(
            length: state.numOfWeeks,
            initialIndex: state.initialIndex,
            child: Column(
              children: [
                Expanded(
                  child: Scaffold(
                    body: TabBarView(
                      children: List<StudentsScheduleTab>.generate(
                        state.numOfWeeks,
                        (index) => StudentsScheduleTab(tabNum: index),
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        //TODO: Кнопка добавления в избранное
                      },
                      child: const Icon(Icons.star_border),
                    ),
                  ),
                ),
                TabBar(
                  tabs: List<Tab>.generate(
                    state.numOfWeeks,
                    (index) {
                      final star = index == state.starIndex ? '★' : '';
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

        if (state is CurrentGroupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CurrentGroupInitial) {
          return Column(
            children: [
              Image.asset(
                'assets/arrowToGroups.png',
                height: 60,
              ),
              const Text(
                'Выберите группу',
                style: TextStyle(fontSize: 16),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Текущая неделя выделена звездочкой ★',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          );
        }

        if (state is CurrentGroupLoadingError) {
          return const Center(child: Text('Ошибка загрузки'));
        }

        return const Text('Неизвестная ошибка');
      },
    );
  }
}
