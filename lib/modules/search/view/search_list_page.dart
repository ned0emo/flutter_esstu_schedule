import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/schedule_type.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/search/search_list_bloc/search_list_bloc.dart';

class SearchListPage extends StatefulWidget {
  final String scheduleType;

  const SearchListPage({super.key, required this.scheduleType});

  @override
  State<StatefulWidget> createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => SearchListBloc(Modular.get())
                ..add(LoadSearchList(widget.scheduleType))),
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
          return Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 15),
              if(state.percents != null) Text('${state.percents}%'),
              if(state.message != null) Text(state.message!),
            ],
          ));
        }

        if (state is SearchListLoaded) {
          return Column(
            children: [
              const SizedBox(height: 15),
              Text(
                  scheduleType == ScheduleType.student
                      ? 'Введите название группы:'
                      : 'Введите фамилию преподавателя:',
                  style: (TextStyle(fontSize: 20))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    BlocProvider.of<SearchListBloc>(context)
                        .add(SearchInList(value));
                  },
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    (state.searchedList ?? []).length,
                    (index) => _searchedElement(state.searchedList![index]),
                  ),
                ),
              ))
            ],
          );
        }

        if (state is SearchingError) {
          return Center(child: Text('Ошибка загрзуки:\n${state.message}'));
        }

        return const Center(child: Text('Неизвестная ошибка'));
      },
    );
  }

  Widget _searchedElement(String name) {
    return ListTile(
      title: Text(name),
      onTap: () {},
    );
  }
}
