import '../play_state.dart';
import 'bot_ai.dart';

class MyAI implements BotAi {
  int _column = 0;
  int _myCoinId = -1;

  MyAI();

  @override
  int play(PlayState playState) {
    if (_myCoinId == -1 && playState.coinId != null) {
      _myCoinId = playState.coinId!;
    }
    //  todo: put your logic code here
    return _column;
  }

  @override
  String getName() {
    //  todo: give your bot a super duper cool name
    return "YourBotName";
  }
}