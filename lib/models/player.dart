class Player {
  final int id;
  final String name;

  const Player({
    required this.id,
    required this.name,
  });

  Player copyWith({String? name}) {
    return Player(
      id: id,
      name: name ?? this.name,
    );
  }
}
