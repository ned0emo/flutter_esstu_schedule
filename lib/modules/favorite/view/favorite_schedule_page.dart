import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/favorite/favorite_update_bloc/favorite_update_bloc.dart';
import 'package:schedule/modules/favorite/view/favorite_schedule_tab.dart';

class FavoriteSchedulePage extends StatefulWidget {
  final String scheduleType;
  final String scheduleName;

  const FavoriteSchedulePage(
      {super.key, required this.scheduleName, required this.scheduleType});

  @override
  State<StatefulWidget> createState() => _FavoriteScheduleState();

  String get fileName => '$scheduleType|$scheduleName';
}

class _FavoriteScheduleState extends State<FavoriteSchedulePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TODO: isNeedUpdate прописать в настройках
        BlocProvider(
            create: (context) => FavoriteScheduleBloc(Modular.get())
              ..add(LoadFavoriteSchedule(widget.fileName, isNeedUpdate: true))),
        BlocProvider(
            create: (context) => FavoriteButtonBloc(Modular.get())
              ..add(CheckSchedule(
                scheduleType: widget.scheduleType,
                name: widget.scheduleName,
              ))),
        BlocProvider(create: (context) => FavoriteUpdateBloc(Modular.get())),
      ],
      child: BlocListener<FavoriteUpdateBloc, FavoriteUpdateState>(
        listener: (context, state) {
          if (state is FavoriteUpdateInitial) {
            _controller.reset();
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message!),
                  duration: const Duration(seconds: 1)));
            }

            return;
          }

          if (state is FavoriteScheduleUpdating) {
            _controller.forward();
            return;
          }

          if (state is FavoriteScheduleUpdated) {
            BlocProvider.of<FavoriteScheduleBloc>(context)
                .add(LoadFavoriteSchedule(state.fileName));

            _controller.reset();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1)));
            return;
          }

          if (state is FavoriteScheduleUpdateError) {
            _controller.reset();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                duration: const Duration(milliseconds: 1500)));
            return;
          }
        },
        child: BlocBuilder<FavoriteScheduleBloc, FavoriteScheduleState>(
          builder: (context, state) {
            if (state is FavoriteScheduleLoading ||
                state is FavoriteScheduleInitial) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            if (state is FavoriteScheduleLoaded) {
              if (state.isNeedUpdate) {
                BlocProvider.of<FavoriteUpdateBloc>(context).add(UpdateSchedule(
                  scheduleName: state.scheduleName,
                  scheduleList: state.scheduleList,
                  scheduleType: state.scheduleType,
                  isAutoUpdate: true,
                  link1: state.link1,
                  link2: state.link2,
                  customDaysOfWeek: state.customDaysOfWeek,
                ));
              }

              return DefaultTabController(
                length: state.numOfWeeks,
                initialIndex: state.weekNumber,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(state.scheduleName),
                    actions: state.link1 == null
                        ? null
                        : [
                            IconButton(
                              onPressed: () {
                                BlocProvider.of<FavoriteUpdateBloc>(context)
                                    .add(UpdateSchedule(
                                  scheduleName: state.scheduleName,
                                  scheduleList: state.scheduleList,
                                  scheduleType: state.scheduleType,
                                  isAutoUpdate: false,
                                  link1: state.link1,
                                  link2: state.link2,
                                  customDaysOfWeek: state.customDaysOfWeek,
                                ));
                              },
                              icon: RotationTransition(
                                turns: Tween(begin: 0.0, end: 10.0)
                                    .animate(_controller),
                                child: const Icon(Icons.refresh),
                              ),
                            ),
                          ],
                  ),
                  body: TabBarView(
                      children: List.generate(
                    state.numOfWeeks,
                    (index) => FavoriteScheduleTab(tabNum: index),
                  )),
                  bottomNavigationBar: TabBar(
                    tabs: List.generate(
                      state.numOfWeeks,
                      (index) {
                        final star = !state.isZo && index == state.weekNumber
                            ? ' ★'
                            : '';
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
          return BlocBuilder<FavoriteUpdateBloc, FavoriteUpdateState>(
            builder: (context, favoriteUpdateState) {
              return BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
                builder: (context, state) {
                  return FloatingActionButton(
                    onPressed: favoriteUpdateState is FavoriteScheduleUpdating
                        ? null
                        : favoriteScheduleState is FavoriteScheduleLoaded
                            ? () {
                                if (state is FavoriteExist) {
                                  BlocProvider.of<FavoriteButtonBloc>(context)
                                      .add(DeleteSchedule(
                                          name: favoriteScheduleState
                                              .scheduleName,
                                          scheduleType: favoriteScheduleState
                                              .scheduleType));
                                  return;
                                }

                                if (state is FavoriteDoesNotExist) {
                                  BlocProvider.of<FavoriteButtonBloc>(context)
                                      .add(SaveSchedule(
                                    name: favoriteScheduleState.scheduleName,
                                    scheduleType:
                                        favoriteScheduleState.scheduleType,
                                    scheduleList:
                                        favoriteScheduleState.scheduleList,
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
          );
        },
      ),
    );
  }
}
