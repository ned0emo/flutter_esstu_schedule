part of 'favorite_update_bloc.dart';

@immutable
abstract class FavoriteUpdateEvent {}

class UpdateSchedule extends FavoriteUpdateEvent {
  final ScheduleModel scheduleModel;
  final bool isAutoUpdate;

  UpdateSchedule({
    required this.scheduleModel,
    required this.isAutoUpdate,
  });

  String get fileName => '${scheduleModel.type}|${scheduleModel.name}';
}
