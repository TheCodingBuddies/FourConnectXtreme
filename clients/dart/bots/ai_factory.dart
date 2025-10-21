import 'bot_ai.dart';
import 'my_ai.dart';
import 'random_ai.dart';

class AiFactory {
  static BotAi create(String type) {
    switch (type) {
      case "RandomAI":
        return RandomAI();
      default:
        return MyAI();
    }
  }
}