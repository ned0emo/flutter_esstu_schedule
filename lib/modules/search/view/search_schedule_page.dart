import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/view/schedule_page_body.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/search/search_schedule_bloc/search_schedule_bloc.dart';

class SearchSchedulePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
            value: Modular.get<SearchScheduleBloc>()
              ..add(LoadSearchingSchedule(
                scheduleName: scheduleName,
                link1: scheduleLink1,
                link2: scheduleLink2,
                scheduleType: scheduleType,
              ))),
        BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: _appBarText()),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return BlocBuilder<SearchScheduleBloc, SearchScheduleState>(
      builder: (context, state) {
        if (state is SearchScheduleLoading || state is SearchScheduleInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SearchScheduleLoaded) {
          return SchedulePageBody<SearchScheduleBloc>(
            scheduleModel: state.scheduleModel,
          );
        }

        if (state is SearchScheduleError) {
          return Center(
              child: Text(state.message, textAlign: TextAlign.center));
        }

        return const Scaffold(body: Center(child: Text('Неизвестная ошибка')));
      },
    );
  }

  Widget _appBarText() {
    return BlocBuilder<SearchScheduleBloc, SearchScheduleState>(
      builder: (context, state) {
        return Text(state.appBarTitle ?? 'Ошибка');
      },
    );
  }
}
