part of 'favorite_button_bloc.dart';

@immutable
abstract class FavoriteButtonEvent {}

class SaveSchedule extends FavoriteButtonEvent {
  final ScheduleModel scheduleModel;

  SaveSchedule({required this.scheduleModel});
}

class DeleteSchedule extends FavoriteButtonEvent {
  final String scheduleType;
  final String name;

  DeleteSchedule({required this.scheduleType, required this.name});
}

class CheckSchedule extends FavoriteButtonEvent {
  final String scheduleType;
  final String name;

  CheckSchedule({required this.scheduleType, required this.name});
}

class AddFavoriteToMainPage extends FavoriteButtonEvent {
  final String name;
  final String scheduleType;

  AddFavoriteToMainPage({required this.scheduleType, required this.name});
}
