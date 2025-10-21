import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'bots/bot_ai.dart';
import 'play_state.dart';

class CustomWebsocketClient {
  final Uri serverUri;
  final BotAi bot;
  late WebSocketChannel _channel;

  CustomWebsocketClient(this.serverUri, this.bot);

  void connect() {
    _channel = WebSocketChannel.connect(serverUri);
    print("Connection to Four Connect Xtreme opened");

    _channel.stream.listen(
          (message) {
        _onMessage(message);
      },
      onDone: () {
        print("Verbindung zum Server geschlossen");
      },
      onError: (error) {
        print("Fehler: $error");
      },
    );
  }

  void _onMessage(dynamic message) {
    if (message is! Uint8List) {
      print("on message string (ignoring): $message");
      return;
    }

    try {
      String decodedMessage = utf8.decode(message)
          .replaceAll("'", "\"");
      print(decodedMessage);

      PlayState response = PlayState.fromJson(jsonDecode(decodedMessage));

      if (response.bot == bot.getName()) {
        final responseMap = {
          "state": "play",
          "column": bot.play(response),
        };
        String jsonResponse = jsonEncode(responseMap);
        _channel.sink.add(jsonResponse);
      }
    } catch (e) {
      if (e is FormatException) {
        print("Got ping message");
      } else {
        print(e);
      }
    }
  }
}