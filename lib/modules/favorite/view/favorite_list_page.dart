import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/settings/settings_repository.dart';

class FavoriteListPage extends StatelessWidget {
  const FavoriteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
            value: Modular.get<FavoriteListBloc>()..add(LoadFavoriteList())),
        BlocProvider.value(value: Modular.get<FavoriteButtonBloc>())
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Избранное'),
          actions: [_clearButton(context)],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? -1) > 0) {
              Modular.to.pop();
            }
          },
          child: BlocBuilder<FavoriteListBloc, FavoriteListState>(
            builder: (context, state) {
              if (state is FavoriteListLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is FavoriteListLoaded) {
                final map = state.favoriteListMap;
                return Center(
                  child: state.favoriteListMap.isEmpty
                      ? const Text(
                          'В избранное пока ничего не добавлено',
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        )
                      : ListView(
                          children: List.generate(
                            map.length,
                            (index) => _favoriteSection(
                              map.keys.elementAt(index),
                              map[map.keys.elementAt(index)]!,
                              context,
                            ),
                          ),
                        ),
                );
              }

              if (state is FavoriteListError) {
                return Center(
                    child: Text(state.message, textAlign: TextAlign.center));
              }

              return const Center(child: Text('Неизвестная ошибка'));
            },
          ),
        ),
      ),
    );
  }

  Widget _favoriteSection(
      String sectionName, List<String> scheduleNameList, BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: AlignmentDirectional.center,
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            _scheduleTypeRussian(sectionName),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        ...List.generate(
          scheduleNameList.length,
          (index) =>
              _favoriteButton(scheduleNameList[index], sectionName, context),
        ),
      ],
    );
  }

  Widget _favoriteButton(
      String scheduleName, String scheduleType, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                Modular.get<FavoriteScheduleBloc>().add(ResetSchedule());
                Modular.to.pushNamed(
                  AppRoutes.favoriteListRoute + AppRoutes.favoriteScheduleRoute,
                  arguments: [
                    scheduleName,
                    scheduleType,
                    (await RepositoryProvider.of<SettingsRepository>(context)
                            .loadSettings())[SettingsTypes.autoUpdate] ==
                        'true'
                  ],
                );
              },
              child: Container(
                height: 50.0,
                alignment: AlignmentDirectional.center,
                child: Text(
                  scheduleName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Modular.get<FavoriteListBloc>()
                  .add(DeleteScheduleFromList(scheduleName, scheduleType));
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Widget _clearButton(BuildContext context) {
    return BlocBuilder<FavoriteListBloc, FavoriteListState>(
      builder: (context, state) {
        return IconButton(
          onPressed: state is FavoriteListLoaded
              ? () {
                  if (state.favoriteListMap.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Очистить избранное?'),
                          actions: [
                            FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Нет')),
                            OutlinedButton(
                                onPressed: () {
                                  Modular.get<FavoriteListBloc>()
                                      .add(ClearAllSchedule());
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Да')),
                          ],
                        );
                      },
                    );
                  }
                }
              : null,
          icon: const Icon(Icons.delete_forever),
        );
      },
    );
  }

  String _scheduleTypeRussian(String type) {
    switch (type) {
      case ScheduleType.classroom:
        return 'Аудитории';
      case ScheduleType.zoClassroom:
        return 'Аудитории (заочное)';
      case ScheduleType.student:
        return 'Учебные группы';
      case ScheduleType.teacher:
        return 'Преподаватели';
      case ScheduleType.zoTeacher:
        return 'Преподаватели (заочное)';
      default:
        return 'Не распознано';
    }
  }
}
