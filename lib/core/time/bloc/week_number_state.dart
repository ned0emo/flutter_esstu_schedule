part of 'week_number_bloc.dart';

@immutable
sealed class WeekNumberState {}

final class WeekNumberInitial extends WeekNumberState {}

final class WeekNumberLoading extends WeekNumberState {}

final class WeekNumberLoaded extends WeekNumberState {}

final class WeekNumberError extends WeekNumberState {}
