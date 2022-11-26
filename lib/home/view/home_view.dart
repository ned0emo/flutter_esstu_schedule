import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  // TODO Нажатие кнопки
                },
                style: _HomeElevatedButtonStyle(),
                child: const _HomeElevatedButtonContent(
                  label: 'Студенты',
                  iconData: FontAwesomeIcons.userGroup,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO Нажатие кнопки
                },
                style: _HomeElevatedButtonStyle(),
                child: const _HomeElevatedButtonContent(
                  label: 'Преподаватели',
                  iconData: FontAwesomeIcons.graduationCap,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO Нажатие кнопки
                },
                style: _HomeElevatedButtonStyle(),
                child: const _HomeElevatedButtonContent(
                  label: 'Аудитории',
                  iconData: FontAwesomeIcons.computer,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO Нажатие кнопки
                },
                style: _HomeElevatedButtonStyle(),
                child: const _HomeElevatedButtonContent(
                  label: 'Избранное',
                  iconData: Icons.star,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO Нажатие кнопки
                },
                style: _HomeElevatedButtonStyle(),
                child: const _HomeElevatedButtonContent(
                  label: 'Поиск',
                  iconData: Icons.search,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeElevatedButtonContent extends StatelessWidget {
  final String label;
  final IconData iconData;

  const _HomeElevatedButtonContent(
      {required this.label, required this.iconData});

  @override
  Widget build(BuildContext context) {
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

class _HomeElevatedButtonStyle extends ButtonStyle {
  @override
  MaterialStateProperty<Color?>? get backgroundColor =>
      MaterialStateProperty.all<Color>(Colors.white);

  @override
  MaterialStateProperty<Color?>? get foregroundColor =>
      MaterialStateProperty.all<Color>(Colors.black87);
}
