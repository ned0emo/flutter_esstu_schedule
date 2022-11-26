import 'package:flutter/material.dart';
import 'package:schedule/home/view/home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание ВСГУТУ'),
        actions: [
          IconButton(
            // TODO Реализовать настройки
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(8),
        child: HomeView(),
      ),
    );
  }
}
