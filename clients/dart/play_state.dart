import 'model/bomb.dart';

class PlayState {
  String? bot;
  int? coinId;
  int? round;
  List<Bomb>? bombs;
  List<List<int>>? board;

  PlayState({
    this.bot,
    this.coinId,
    this.round,
    this.bombs,
    this.board,
  });

  factory PlayState.fromJson(Map<String, dynamic> json) {
    return PlayState(
      bot: json['bot'],
      coinId: json['coin_id'],
      round: json['round'],
      bombs: (json['bombs'] as List<dynamic>?)
          ?.map((e) => Bomb.fromJson(e as Map<String, dynamic>))
          .toList(),
      board: (json['board'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).cast<int>())
          .toList(),
    );
  }
}