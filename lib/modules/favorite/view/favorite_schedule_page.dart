import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/core/view/schedule_page_body.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';
import 'package:schedule/modules/favorite/favorite_update_bloc/favorite_update_bloc.dart';

class FavoriteSchedulePage extends StatefulWidget {
  final String scheduleType;
  final String scheduleName;
  final bool isAutoUpdateEnabled;

  const FavoriteSchedulePage({
    super.key,
    required this.scheduleName,
    required this.scheduleType,
    required this.isAutoUpdateEnabled,
  });

  String get fileName => '$scheduleType|$scheduleName';

  @override
  State<StatefulWidget> createState() => _FavoriteScheduleState();
}

class _FavoriteScheduleState extends State<FavoriteSchedulePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
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
        BlocProvider.value(
            value: Modular.get<FavoriteScheduleBloc>()
              ..add(LoadFavoriteSchedule(widget.fileName,
                  isNeedUpdate: widget.isAutoUpdateEnabled))),
        BlocProvider.value(value: Modular.get<FavoriteButtonBloc>()),
        BlocProvider.value(value: Modular.get<FavoriteUpdateBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FavoriteUpdateBloc, FavoriteUpdateState>(
            listener: (context, state) {
              if (state is FavoriteUpdateInitial) {
                _controller.reset();
                if (state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message!),
                      duration: const Duration(seconds: 2)));
                }

                return;
              }

              if (state is FavoriteScheduleUpdating) {
                _controller.forward();
                return;
              }

              if (state is FavoriteScheduleUpdated) {
                Modular.get<FavoriteScheduleBloc>()
                    .add(LoadFavoriteSchedule(state.fileName));

                _controller.reset();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 2)));
                return;
              }

              if (state is FavoriteScheduleUpdateError) {
                _controller.reset();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 2)));
                return;
              }
            },
          ),
          BlocListener<FavoriteScheduleBloc, FavoriteScheduleState>(
            listener: (context, state) {
              if (state is FavoriteScheduleLoaded) {
                if (state.isNeedUpdate) {
                  Modular.get<FavoriteUpdateBloc>().add(UpdateSchedule(
                    scheduleModel: state.scheduleModel,
                    isAutoUpdate: true,
                  ));
                }
              }
            },
          ),
          BlocListener<FavoriteButtonBloc, FavoriteButtonState>(
            listener: (context, state) {
              Modular.get<FavoriteListBloc>().add(LoadFavoriteList());
              //if(state is FavoriteDoesNotExist){
              //  Modular.get<FavoriteListBloc>().add(LoadFavoriteList());
              //}
            },
          )
        ],
        child: Scaffold(
          appBar: AppBar(
            title: _appBarText(),
            actions: [_appBarRefreshButton()],
          ),
          body: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return BlocBuilder<FavoriteScheduleBloc, FavoriteScheduleState>(
      builder: (context, state) {
        if (state is FavoriteScheduleLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FavoriteScheduleLoaded) {
          return SchedulePageBody(
            scheduleModel: state.scheduleModel,
          );
        }

        if (state is FavoriteScheduleError) {
          return Center(
              child: Text(
            state.message,
            textAlign: TextAlign.center,
          ));
        }

        return const Center(child: Text('Неизвестная ошибка...'));
      },
    );
  }

  Widget _appBarText() {
    return BlocBuilder<FavoriteScheduleBloc, FavoriteScheduleState>(
      builder: (context, state) {
        if (state is FavoriteScheduleLoaded) {
          return Text(state.scheduleModel.name);
        }

        if (state is FavoriteScheduleError) {
          return const Text('Ошибка');
        }

        return const Text('Загрузка');
      },
    );
  }

  Widget _appBarRefreshButton() {
    return BlocBuilder<FavoriteScheduleBloc, FavoriteScheduleState>(
      builder: (context, state) {
        if (state is FavoriteScheduleLoaded &&
            widget.scheduleType != ScheduleType.classroom &&
            widget.scheduleType != ScheduleType.zoClassroom &&
            widget.scheduleType != ScheduleType.zoTeacher) {
          return IconButton(
            onPressed: () {
              Modular.get<FavoriteUpdateBloc>().add(UpdateSchedule(
                scheduleModel: state.scheduleModel,
                isAutoUpdate: false,
              ));
            },
            icon: RotationTransition(
              turns: Tween(begin: 0.0, end: 30.0).animate(_controller),
              child: const Icon(Icons.refresh),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
