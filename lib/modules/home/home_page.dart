import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schedule/core/app_routes.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  /*final _elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
  );*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание ВСГУТУ'),
        actions: [
          IconButton(
            onPressed: () {
              Modular.to.pushNamed(AppRoutes.settingsRoute);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  padding: const EdgeInsets.all(15),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  crossAxisCount: 2,
                  children: <Widget>[
                    Image.asset(
                      'assets/newlogo.png',
                      width: 160,
                      height: 160,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.studentsRoute);
                      },
                      //style: _elevatedButtonStyle,
                      child: _homeElevatedButton(
                        'Студенты',
                        FontAwesomeIcons.userGroup,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.teachersRoute);
                      },
                      //style: _elevatedButtonStyle,
                      child: _homeElevatedButton(
                        'Преподаватели',
                        FontAwesomeIcons.graduationCap,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.classesRoute);
                      },
                      //style: _elevatedButtonStyle,
                      child: _homeElevatedButton(
                        'Аудитории',
                        FontAwesomeIcons.computer,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.favoriteListRoute);
                      },
                      //style: _elevatedButtonStyle,
                      child: _homeElevatedButton(
                        'Избранное',
                        Icons.star,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO Нажатие кнопки
                      },
                      //style: _elevatedButtonStyle,
                      child: _homeElevatedButton(
                        'Поиск',
                        Icons.search,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _homeElevatedButton(String label, IconData iconData) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            iconData,
            size: 70,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
