import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/favorite/view/favorite_schedule_tab.dart';

class FavoriteSchedulePage extends StatefulWidget {
  final String scheduleName;

  const FavoriteSchedulePage({super.key, required this.scheduleName});

  @override
  State<StatefulWidget> createState() => _FavoriteScheduleState();
}

class _FavoriteScheduleState extends State<FavoriteSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => FavoriteScheduleBloc(Modular.get())
              ..add(LoadFavoriteSchedule(widget.scheduleName))),
        BlocProvider(create: (context) => FavoriteButtonBloc(Modular.get())),
      ],
      child: BlocBuilder<FavoriteScheduleBloc, FavoriteScheduleState>(
        builder: (context, state) {
          if (state is FavoriteScheduleLoading ||
              state is FavoriteScheduleInitial) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (state is FavoriteScheduleLoaded) {
            return DefaultTabController(
              length: state.numOfWeeks,
              initialIndex: state.weekNumber,
              child: Scaffold(
                appBar: AppBar(title: Text(state.currentScheduleName)),
                body: TabBarView(
                    children: List.generate(
                  state.numOfWeeks,
                  (index) => FavoriteScheduleTab(tabNum: index),
                )),
                bottomNavigationBar: TabBar(
                  tabs: List.generate(
                    state.numOfWeeks,
                    (index) {
                      final star =
                          !state.isZo && index == state.weekNumber ? ' ★' : '';
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
                floatingActionButton: _floatingActionButton(context),
              ),
            );
          }

          if (state is FavoriteScheduleError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }

          return const Scaffold(
              body: Center(child: Text('Неизвестная ошибка')));
        },
      ),
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return BlocListener<FavoriteButtonBloc, FavoriteButtonState>(
      listener: (context, state) {
        Modular.get<FavoriteListBloc>().add(LoadFavoriteList());

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
      child: BlocBuilder<FavoriteScheduleBloc, FavoriteScheduleState>(
        builder: (context, favoriteScheduleState) {
          return BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
            builder: (context, state) {
              return FloatingActionButton(
                onPressed: favoriteScheduleState is FavoriteScheduleLoaded
                    ? () {
                        if (state is FavoriteExist) {
                          BlocProvider.of<FavoriteButtonBloc>(context).add(DeleteSchedule(
                              name: favoriteScheduleState.currentScheduleName,
                              scheduleType:
                                  favoriteScheduleState.scheduleType));
                          return;
                        }

                        if (state is FavoriteDoesNotExist) {
                          BlocProvider.of<FavoriteButtonBloc>(context).add(SaveSchedule(
                            name: favoriteScheduleState.currentScheduleName,
                            scheduleType: favoriteScheduleState.scheduleType,
                            scheduleList: favoriteScheduleState.scheduleList,
                            link1: favoriteScheduleState.link1,
                            link2: favoriteScheduleState.link2,
                            daysOfWeekList:
                                favoriteScheduleState.customDaysOfWeek,
                          ));
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
}
