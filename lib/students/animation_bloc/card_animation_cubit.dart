import 'package:bloc/bloc.dart';

part 'card_animation_state.dart';

class CardAnimationCubit extends Cubit<CardAnimationState> {
  CardAnimationCubit() : super(CardAnimationOpened());

  Future<void> openCard(int cardIndex) async {

  }

  Future<void> closeCard(int openedCardIndex) async {

  }
}
