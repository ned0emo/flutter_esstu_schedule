part of 'current_group_bloc.dart';

@immutable
abstract class CurrentGroupEvent {}

class LoadGroup extends CurrentGroupEvent{
  final String scheduleName;
  final String link;

  LoadGroup({required this.scheduleName, required this.link});

  bool get isZo => link.contains('zo') ? true : false;
}
