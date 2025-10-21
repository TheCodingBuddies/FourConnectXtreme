import 'bots/ai_factory.dart';
import 'bots/bot_ai.dart';
import 'custom_websocket_client.dart';

void main(List<String> args) async {
  final bot = _getBot(args);
  final port = _getPort(args);

  final serverUri = 'ws://localhost:$port/${bot.getName()}';

  final client = CustomWebsocketClient(Uri.parse(serverUri), bot);
  client.connect();
}

BotAi _getBot(List<String> args) {
  if (args.isNotEmpty) {
    return AiFactory.create(args[0]);
  } else {
    return AiFactory.create("MyAI");
  }
}

int _getPort(List<String> args) {
  if (args.length > 1) {
    return int.parse(args[1]);
  } else {
    return 5051;
  }
}