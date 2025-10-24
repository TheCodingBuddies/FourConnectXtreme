import '../play_state.dart';

abstract class BotAi {
  int play(PlayState playState);
  String getName();
}