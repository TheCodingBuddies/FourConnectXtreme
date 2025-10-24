class Bomb {
  final int row;
  final int col;
  final int explode_in_round;

  Bomb({required this.row, required this.col, required this.explode_in_round});

  factory Bomb.fromJson(Map<String, dynamic> json) {
    return Bomb(
      row: json['row'] as int,
      col: json['col'] as int,
      explode_in_round: json['explode_in_round'] as int,
    );
  }
}