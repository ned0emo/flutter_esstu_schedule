import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:schedule/core/app_routes.dart';
import 'package:schedule/modules/favorite/favorite_button_bloc/favorite_button_bloc.dart';
import 'package:schedule/modules/favorite/favorite_list_bloc/favorite_list_bloc.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  Modular.get<FavoriteListBloc>()..add(LoadFavoriteList())),
          BlocProvider(create: (context) => Modular.get<FavoriteButtonBloc>())
        ],
        child: Center(
          child: SingleChildScrollView(
            child: BlocBuilder<FavoriteListBloc, FavoriteListState>(
              builder: (context, state) {
                if (state is FavoriteListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FavoriteListLoaded) {
                  final list = state.favoriteList;
                  return Center(
                    child: Column(
                      children: List.generate(
                          list.length, (index) => _favoriteButton(list[index])),
                    ),
                  );
                }

                if (state is FavoriteListError) {
                  return Center(child: Text(state.message));
                }

                return const Center(child: Text('Неизвестная ошибка'));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _favoriteButton(String scheduleName) {
    return Column(
      children: [
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            Modular.to.pushNamed(
                AppRoutes.favoriteListRoute + AppRoutes.favoriteScheduleRoute,
                arguments: [scheduleName]);
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(350, 50),
              maximumSize: const Size(350, double.infinity)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(scheduleName, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
