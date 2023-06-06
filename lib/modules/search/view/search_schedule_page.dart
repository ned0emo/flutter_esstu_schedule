import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/view/schedule_tab.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/search/search_schedule_bloc/search_schedule_bloc.dart';

class SearchSchedulePage extends StatefulWidget {
  final String scheduleName;
  final String scheduleLink1;
  final String? scheduleLink2;
  final String scheduleType;

  const SearchSchedulePage({
    super.key,
    required this.scheduleName,
    required this.scheduleLink1,
    this.scheduleLink2,
    required this.scheduleType,
  });

  @override
  State<StatefulWidget> createState() => _SearchSchedulePageState();

  String get fileName => '$scheduleType|$scheduleName';
}

class _SearchSchedulePageState extends State<SearchSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => SearchScheduleBloc(Modular.get())
              ..add(LoadSearchingSchedule(
                scheduleName: widget.scheduleName,
                link1: widget.scheduleLink1,
                link2: widget.scheduleLink2,
                scheduleType: widget.scheduleType,
              ))),
        BlocProvider(
            create: (context) => FavoriteButtonBloc(Modular.get())
              ..add(CheckSchedule(
                scheduleType: widget.scheduleType,
                name: widget.scheduleName,
              ))),
      ],
      child: BlocBuilder<SearchScheduleBloc, SearchScheduleState>(
        builder: (context, state) {
          if (state is SearchScheduleLoading ||
              state is SearchScheduleInitial) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (state is SearchScheduleLoaded) {
            return DefaultTabController(
              length: state.numOfWeeks,
              initialIndex: state.weekNumber,
              child: Scaffold(
                appBar: AppBar(title: Text(state.scheduleName)),
                body: TabBarView(
                    children: List.generate(
                  state.numOfWeeks,
                  (index) => ScheduleTab(
                    tabNum: index,
                    scheduleName: state.scheduleName,
                    scheduleList: state.scheduleList,
                    customDaysOfWeek: state.customDaysOfWeek,
                  ),
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

          if (state is SearchScheduleError) {
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
      child: BlocBuilder<SearchScheduleBloc, SearchScheduleState>(
        builder: (context, searchScheduleState) {
          return BlocBuilder<FavoriteButtonBloc, FavoriteButtonState>(
            builder: (context, state) {
              return FloatingActionButton(
                onPressed: searchScheduleState is SearchScheduleLoaded
                    ? () {
                        if (state is FavoriteExist) {
                          BlocProvider.of<FavoriteButtonBloc>(context).add(
                              DeleteSchedule(
                                  name: searchScheduleState.scheduleName,
                                  scheduleType:
                                      searchScheduleState.scheduleType));
                          return;
                        }

                        if (state is FavoriteDoesNotExist) {
                          BlocProvider.of<FavoriteButtonBloc>(context)
                              .add(SaveSchedule(
                            name: searchScheduleState.scheduleName,
                            scheduleType: searchScheduleState.scheduleType,
                            scheduleList: searchScheduleState.scheduleList,
                            link1: searchScheduleState.link1,
                            link2: searchScheduleState.link2,
                            daysOfWeekList:
                                searchScheduleState.customDaysOfWeek,
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
