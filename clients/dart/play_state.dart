class PlayState {
  String? bot;
  int? coinId;
  int? round;
  List<Map<String, int>>? bombs;
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
          ?.map((e) => Map<String, int>.from(e))
          .toList(),
      board: (json['board'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).cast<int>())
          .toList(),
    );
  }
}