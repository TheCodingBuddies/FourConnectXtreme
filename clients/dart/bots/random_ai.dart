import 'dart:math';
import '../play_state.dart';
import 'bot_ai.dart';

class RandomAI implements BotAi {
  int _column = 0;
  final Random _random = Random();

  RandomAI();

  @override
  int play(PlayState playState) {
    _column = _random.nextInt(7);
    return _column;
  }

  @override
  String getName() {
    return "RandomBot";
  }
}