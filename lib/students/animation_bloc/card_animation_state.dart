part of 'card_animation_cubit.dart';

class CardAnimationState {
  final int? height;

  CardAnimationState(this.height);
}

class CardAnimationOpened extends CardAnimationState {
  CardAnimationOpened() : super(null);
}

class CardAnimationClosed extends CardAnimationState {
  CardAnimationClosed() : super(0);
}
