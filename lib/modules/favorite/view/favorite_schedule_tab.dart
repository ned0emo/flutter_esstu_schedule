import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:jiffy/jiffy.dart';
import 'package:schedule/modules/favorite/favorite_schedule_bloc/favorite_schedule_bloc.dart';

class FavoriteScheduleTab extends StatefulWidget {
  final int tabNum;

  const FavoriteScheduleTab({super.key, required this.tabNum});

  @override
  State<StatefulWidget> createState() => _FavoriteScheduleTabState();
}

class _FavoriteScheduleTabState extends State<FavoriteScheduleTab> {
  final List<String> lessonTimeList = [
    '9:00\n10:35',
    '10:45\n12:20',
    '13:00\n14:35',
    '14:45\n16:20',
    '16:25\n18:00',
    '18:05\n19:40',
    '19:45\n21:20',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteScheduleBloc, FavoriteScheduleState>(
      builder: (context, state) {
        if (state is FavoriteScheduleLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FavoriteScheduleError) {
          return Center(child: Text(state.message));
        }

        if (state is FavoriteScheduleLoaded) {
          final currentDay = Jiffy().dateTime.weekday - 1;

          return ListView.builder(
            itemBuilder: (context, index) {
              String? dayOfWeek;
              dayOfWeek = state.daysOfWeek[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _dayOfWeekCard(
                  index,
                  state.scheduleList[index + widget.tabNum * 6],
                  index == currentDay,
                  dayOfWeek,
                  state,
                ),
              );
            },
            itemCount: 6,
          );
        }

        return const Center(child: Text('Неизвестная ошибка'));
      },
    );
  }

  Widget _dayOfWeekCard(int currentCardIndex, List<String> scheduleList,
      bool isCurrentDay, String dayOfWeek, FavoriteScheduleLoaded state) {
    /// номер пары. начинается с -1 потому что в цикле добавления пары
    /// в карточку первым действием он плюсуется. Так как это значение
    /// также используется как индекс массива
    int lessonNumber = -1;

    int currentLesson = state.currentLesson;
    bool isCurrentDayOpened = state.openedDayIndex == currentCardIndex;

    /// Карточка дня недели с расписанием
    ///
    /// [dayOfWeekIndex] нужен для определения, какая карочка будет раскрытой
    ///
    /// [scheduleList] - лист с предметами текущего дня
    ///
    /// [isCurrentDay] определяет, открыта ли карточка при загрузке расписания
    ///
    /// [dayOfWeek] - название дня недели
    return Card(
      child: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              Modular.get<FavoriteScheduleBloc>()
                  .add(ChangeOpenedDay(currentCardIndex));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.transparent,
              ),
              minimumSize: const Size(400, 60),
            ),
            child: Text(
              dayOfWeek,
              style: const TextStyle(fontSize: 24, color: Colors.black87),
            ),
          ),

          /// Если день открыт и лист расписания не переполнен,
          /// то создаем виджеты для предметов
          isCurrentDayOpened
              ? scheduleList.length <= lessonTimeList.length
                  ? Column(
                      children: scheduleList.map(
                            (String lesson) {
                              lessonNumber++;

                              return _lessonSection(
                                lessonNumber + 1,
                                lessonTimeList[lessonNumber],
                                lesson,
                                isCurrentDay && lessonNumber == currentLesson,
                              );
                            },
                          ).toList() +
                          [const SizedBox(height: 10)],
                    )
                  : const Text(
                      'Ошибка загрузки расписания. Лист расписания переполнен')
              : const SizedBox(),
        ],
      ),
    );
  }

  /// Строка пары с номером и временем
  Widget _lessonSection(int lessonNumber, String lessonTime, String lesson,
      bool isCurrentLesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const Divider(),

          ///Для вертиклаьных разделителей
          IntrinsicHeight(
            child: Row(
              children: [
                Center(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: isCurrentLesson
                            ? const Color(0xFFFA8D62)
                            : const Color(0xFF6EB5C0),
                        size: 30,
                      ),
                      Text(
                        lessonNumber.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      lessonTime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: Text(
                    lesson,
                    style: isCurrentLesson
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
