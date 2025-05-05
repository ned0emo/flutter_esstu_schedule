import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../settings/bloc/settings_bloc.dart';
import '../bloc/custom_timetable_bloc.dart';

class CustomTimetablePage extends StatefulWidget {
  const CustomTimetablePage({super.key});

  @override
  State<CustomTimetablePage> createState() => _CustomTimetablePageState();
}

class _CustomTimetablePageState extends State<CustomTimetablePage>
    with TickerProviderStateMixin {
  TabController? _tabController;

  ///настройки
  bool showEmptyDays = true;
  bool showEmptyLessons = true;
  bool showTabDate = true;
  double sdk35Padding = 0;

  @override
  void initState() {
    super.initState();

    final settingsState = BlocProvider.of<SettingsBloc>(context).state;
    if (settingsState is SettingsLoaded) {
      showEmptyDays = !settingsState.hideSchedule;
      showEmptyLessons = !settingsState.hideLesson;
      showTabDate = settingsState.showTabDate;
      sdk35Padding = settingsState.sdkVersion >= 35 ? 12.0 : 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<CustomTimetableBloc>(),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [],
            ),
          )
        ],
      ),
    );
  }

  Widget _tabBarView() {
    return BlocBuilder<CustomTimetableBloc, CustomTimetableState>(
      builder: (context, state) {
        if (state.scheduleModel.numOfWeeks == 0) {
          return const Center(
            child: Text(
              'Расписание отсутствует',
              textAlign: TextAlign.center,
            ),
          );
        }

        _tabController?.dispose();
        _tabController =
            TabController(length: state.scheduleModel.numOfWeeks, vsync: this);

        return TabBarView(
          controller: _tabController,
          children: state.scheduleModel.weeks.map((week) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 50),

            );
          }).toList(),
        );
      },
    );
  }
}
