import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/view/schedule_tab.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/search/search_schedule_bloc/search_schedule_bloc.dart';
import 'package:schedule/modules/settings/bloc/settings_bloc.dart';

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
  late bool hideSchedule;

  @override
  void initState() {
    final settingsState = BlocProvider.of<SettingsBloc>(context).state;
    if(settingsState is SettingsLoaded){
      hideSchedule = settingsState.hideSchedule;
    }
    else{
      hideSchedule = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
            value: Modular.get<SearchScheduleBloc>()
              ..add(LoadSearchingSchedule(
                scheduleName: widget.scheduleName,
                link1: widget.scheduleLink1,
                link2: widget.scheduleLink2,
                scheduleType: widget.scheduleType,
              ))),
        BlocProvider.value(
            value: Modular.get<FavoriteButtonBloc>()
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
                    hideSchedule: hideSchedule,
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
                  labelStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                floatingActionButton: _floatingActionButton(context),
              ),
            );
          }

          if (state is SearchScheduleError) {
            return Scaffold(
                body: Center(
                    child: Text(
              state.message,
              textAlign: TextAlign.center,
            )));
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
                          Modular.get<FavoriteButtonBloc>().add(DeleteSchedule(
                              name: searchScheduleState.scheduleName,
                              scheduleType: searchScheduleState.scheduleType));
                          return;
                        }

                        if (state is FavoriteDoesNotExist) {
                          Modular.get<FavoriteButtonBloc>().add(SaveSchedule(
                            name: searchScheduleState.scheduleName,
                            scheduleType: searchScheduleState.scheduleType,
                            scheduleList: searchScheduleState.scheduleList,
                            link1: searchScheduleState.link1,
                            link2: searchScheduleState.link2,
                            daysOfWeekList:
                                searchScheduleState.customDaysOfWeek,
                          ));

                          _addToMainDialog();
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

  Future<void> _addToMainDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Открывать при запуске приложения?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Нет')),
            TextButton(
                onPressed: () {
                  Modular.get<FavoriteButtonBloc>().add(AddFavoriteToMainPage(
                    scheduleType: widget.scheduleType,
                    name: widget.scheduleName,
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('Да')),
          ],
        );
      },
    );
  }
}
