part of 'custom_timetable_bloc.dart';

@immutable
sealed class CustomTimetableState {
  final ScheduleModel scheduleModel;

  const CustomTimetableState(this.scheduleModel);
}

final class CustomTimetableDataState extends CustomTimetableState {
  CustomTimetableDataState() : super(ScheduleModel.custom());

  const CustomTimetableDataState.ready(super.scheduleModel);
}

final class CustomTimeTableBusyState extends CustomTimetableState {
  const CustomTimeTableBusyState(super.scheduleModel);
}

final class CustomTimetableErrorState extends CustomTimetableState {
  final String message;

  const CustomTimetableErrorState(super.scheduleModel, this.message);
}
