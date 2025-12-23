class Horse {
  final int id;
  final String name;
  final String? playerName;
  int position;

  Horse({
    required this.id,
    required this.name,
    required this.position,
    this.playerName,
  });
}
