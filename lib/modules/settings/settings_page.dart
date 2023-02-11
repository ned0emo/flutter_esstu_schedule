import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget{
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: SettingsList(
        //TODO: Разобраться с темой
        lightTheme: SettingsThemeData(
          titleTextColor: Theme.of(context).colorScheme.onBackground
        ),
        sections: [
          SettingsSection(
            title: const Text('Основные'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                initialValue: true,
                onToggle: (value) {},
                title: const Text('Горизонтальная прокрутка'),
                description:
                const Text('Между неделями можно перемещаться свайпами'),
              ),
              SettingsTile.switchTile(
                initialValue: false,
                onToggle: (value) {},
                title: const Text('Темная тема'),
                description:
                const Text('Интерфейс приложения оформлен в светлых цветах'),
              ),
              SettingsTile.switchTile(
                initialValue: true,
                onToggle: (value) {},
                title: const Text('Автоматически обновлять расписание'),
                description: const Text(
                    'Расписание в избранном будет обновляться автоматически после открытия'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('О приложении'),
            tiles: <SettingsTile>[
              SettingsTile(
                title: const Text('Версия 3.0.0'),
                description: const Text('Разработчик: Александр Суворов'
                    '\nКафедра "Программная инженерия и искусственный интеллект"'
                    '\nВСГУТУ, 2022'
                    '\n\nСвязь с разработчиком:'
                    '\nAlexandr42suv@mail.ru'
                    '\n\nЗначок приложения основан на иконке от SmashIcons:'
                    '\nwww.flaticon.com/authors/smashicons'
                    '\n\nСоциализм или варварство'),
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

}