import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:schedule/core/errors.dart';
import 'package:schedule/core/logger.dart';
import 'package:schedule/core/schedule_time_data.dart';
import 'package:schedule/modules/favorite/repository/favorite_repository.dart';

part 'favorite_update_event.dart';

part 'favorite_update_state.dart';

class FavoriteUpdateBloc
    extends Bloc<FavoriteUpdateEvent, FavoriteUpdateState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteUpdateBloc(FavoriteRepository repository)
      : _favoriteRepository = repository,
        super(FavoriteUpdateInitial()) {
    on<FavoriteUpdateEvent>((event, emit) {});
    on<UpdateSchedule>(_updateSchedule);
  }

  Future<void> _updateSchedule(
      UpdateSchedule event, Emitter<FavoriteUpdateState> emit) async {
    if (event.link1 == null || state is FavoriteScheduleUpdating) return;

    emit(FavoriteScheduleUpdating());

    try {
      final pagesList = await _favoriteRepository
          .loadSchedulePages(event.link1!, link2: event.link2);

      pagesList.removeWhere((element) => !element.contains(event.scheduleName));

      if (pagesList.isEmpty) {
        emit(FavoriteScheduleUpdateError(Logger.warning(
          title: Errors.updateError,
          exception: 'Расписание не найдено по сохраненной ссылке',
        )));
        return;
      }

      ///Дни недели для заочников
      List<String>? customDaysOfWeek =
          event.customDaysOfWeek == null ? null : [];

      final numOfDays = event.customDaysOfWeek?.length ?? 12;
      final numOfLessons = numOfDays == 12 ? 5 : 6;
      final scheduleList = List.generate(
          numOfDays, (index) => List.generate(numOfLessons + 1, (index) => ''));

      for (String page in pagesList) {
        final scheduleSection = page
            .substring(page.indexOf(event.scheduleName))
            .replaceAll(' COLOR="#0000ff"', '');

        final daysOfWeekFromPage =
            scheduleSection.split('SIZE=2><P ALIGN="CENTER">').skip(1);

        int j = 0;
        for (String dayOfWeek in daysOfWeekFromPage) {
          if (j == numOfDays) {
            break;
          }

          if (customDaysOfWeek != null) {
            try {
              customDaysOfWeek.add(
                  dayOfWeek.substring(0, dayOfWeek.indexOf('</B>')).trim());
            } catch (e, stack) {
              Logger.warning(
                title: Errors.pageParsingError,
                exception: e,
                stack: stack,
              );

              customDaysOfWeek.add(
                  ScheduleTimeData.daysOfWeek[customDaysOfWeek.length % 7]);
            }
          }

          final lessons = dayOfWeek.split('SIZE=1><P ALIGN="CENTER">').skip(1);

          int i = 0;
          for (String lessonSection in lessons) {
            final lesson = lessonSection
                .substring(0, lessonSection.indexOf('</FONT>'))
                .trim();

            if (scheduleList[j][i].length < lesson.length) {
              scheduleList[j][i] = lesson;
            }
            i++;
            if (i > numOfLessons) {
              break;
            }
          }

          j++;
        }
      }

      const dce = DeepCollectionEquality();
      if (!dce.equals(scheduleList, event.scheduleList)) {
        final currentScheduleFavoriteModel =
            await _favoriteRepository.getScheduleModel(event.fileName);

        if (currentScheduleFavoriteModel == null) {
          emit(FavoriteScheduleUpdateError(Logger.error(
            title: Errors.updateError,
            exception:
                'Расписание не найдено в хранилище. currentScheduleModel == null',
          )));
          return;
        }

        await _favoriteRepository.saveSchedule(
            event.fileName,
            currentScheduleFavoriteModel
                .copyWith(
                  scheduleList: scheduleList,
                  daysOfWeekList: customDaysOfWeek,
                )
                .toString());

        emit(FavoriteScheduleUpdated(
            scheduleName: event.scheduleName,
            scheduleType: event.scheduleType,
            message: 'Расписание обновлено'));
        return;
      }

      if (event.isAutoUpdate) {
        emit(FavoriteUpdateInitial());
      } else {
        emit(FavoriteUpdateInitial(message: 'Расписание обновлено'));
      }
    } catch (e, stack) {
      emit(FavoriteScheduleUpdateError(Logger.warning(
        title: Errors.updateError,
        exception: e,
        stack: stack,
      )));
    }
  }
}
