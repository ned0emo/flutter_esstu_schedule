import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
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
        BlocProvider(create: (context) => Modular.get<FavoriteButtonBloc>()),
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
              length: 2,
              initialIndex: state.weekNumber,
              child: Scaffold(
                appBar: AppBar(title: Text(state.currentScheduleName)),
                body: const TabBarView(children: [
                  FavoriteScheduleTab(tabNum: 0),
                  FavoriteScheduleTab(tabNum: 1),
                ]),
                bottomNavigationBar: TabBar(
                  tabs: List.generate(
                    2,
                    (index) {
                      final star = index == state.weekNumber ? ' ★' : '';
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
}
