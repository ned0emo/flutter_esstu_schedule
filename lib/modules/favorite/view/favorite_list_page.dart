import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/static/settings_types.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
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
        appBar: AppBar(title: const Text('Избранное')),
        body: Center(
          child: SingleChildScrollView(
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
                        : Column(
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
        floatingActionButton: _clearFloatingButton(context),
      ),
    );
  }

  Widget _favoriteSection(
      String sectionName, List<String> scheduleNameList, BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        Center(
          child: Text(
            ScheduleType.scheduleTypeRussian(sectionName),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        ...List.generate(
            scheduleNameList.length,
            (index) =>
                _favoriteButton(scheduleNameList[index], sectionName, context))
      ],
    );
  }

  Widget _favoriteButton(
      String scheduleName, String scheduleType, BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Modular.to.pushNamed(
                        AppRoutes.favoriteListRoute +
                            AppRoutes.favoriteScheduleRoute,
                        arguments: [
                          scheduleName,
                          scheduleType,
                          (await RepositoryProvider.of<SettingsRepository>(
                                      context)
                                  .loadSettings())[SettingsTypes.autoUpdate] ==
                              'true'
                        ]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(scheduleName, textAlign: TextAlign.center),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                  onPressed: () {
                    Modular.get<FavoriteListBloc>().add(
                        DeleteScheduleFromList(scheduleName, scheduleType));
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).textTheme.titleLarge?.color ??
                        Colors.black87,
                  ))
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _clearFloatingButton(BuildContext context) {
    return BlocBuilder<FavoriteListBloc, FavoriteListState>(
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: state is FavoriteListLoaded
              ? () {
                  if (state.favoriteListMap.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Очистить избранное?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Нет')),
                            TextButton(
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
          child: const Icon(Icons.delete, color: Colors.white),
        );
      },
    );
  }
}
