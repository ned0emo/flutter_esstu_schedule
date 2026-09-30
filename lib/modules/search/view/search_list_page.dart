import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/static/app_routes.dart';
import 'package:schedule/core/static/schedule_type.dart';
import 'package:schedule/modules/search/search_list_bloc/search_list_bloc.dart';

class SearchListPage extends StatefulWidget {
  final String scheduleType;

  const SearchListPage({super.key, required this.scheduleType});

  @override
  State<StatefulWidget> createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  @override
  void initState() {
    super.initState();

    inject<SearchListBloc>().add(LoadSearchList(widget.scheduleType));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: inject<SearchListBloc>()),
        ],
        child: Scaffold(
          appBar: AppBar(
              title: Text(widget.scheduleType == ScheduleType.teacher
                  ? 'Поиск преподавателя'
                  : 'Поиск учебной группы')),
          body: _body(context, widget.scheduleType),
        ));
  }

  Widget _body(BuildContext context, String scheduleType) {
    return BlocBuilder<SearchListBloc, SearchListState>(
      builder: (context, state) {
        if (state is SearchListLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 15),
                Text('${state.percents}%'),
                Text(state.message, textAlign: TextAlign.center),
              ],
            ),
          );
        }

        if (state is SearchListLoaded) {
          return Column(
            children: [
              const SizedBox(height: 15),
              Text(
                  scheduleType == ScheduleType.student
                      ? 'Введите название группы:'
                      : 'Введите фамилию преподавателя:',
                  style: (const TextStyle(fontSize: 20))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    inject<SearchListBloc>().add(SearchInList(value));
                  },
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    (state.searchedList ?? []).length,
                    (index) {
                      final name = state.searchedList![index];
                      final link1 = state.scheduleLinksMap[name]![0];
                      final link2 = state.scheduleLinksMap[name]!.length > 1
                          ? state.scheduleLinksMap[name]![1]
                          : null;

                      return _searchedElement(name, link1, link2, context);
                    },
                  ),
                ),
              ))
            ],
          );
        }

        if (state is SearchingError) {
          return Center(
            child: Text(state.message, textAlign: TextAlign.center),
          );
        }

        return const Center(child: Text('Неизвестная ошибка'));
      },
    );
  }

  Widget _searchedElement(
      String name, String link1, String? link2, BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: () {
        context.pushNamed(
            AppRoutes.searchRoute + AppRoutes.searchingScheduleRoute,
            arguments: [name, widget.scheduleType, link1, link2]);
      },
    );
  }
}
