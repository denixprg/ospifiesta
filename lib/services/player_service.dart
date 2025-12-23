import '../models/player.dart';

class PlayerService {
  PlayerService._internal();

  static final PlayerService _instance = PlayerService._internal();

  factory PlayerService() => _instance;

  final List<Player> _players = [];
  int _currentIndex = 0;

  int _nextId = 1;

  List<Player> get players => List.unmodifiable(_players);

  bool get hasEnoughPlayers => _players.length >= 2;

  void addPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _players.add(Player(id: _nextId++, name: trimmed));
    _currentIndex = _currentIndex.clamp(0, _players.length - 1);
  }

  void removePlayer(int id) {
    _players.removeWhere((player) => player.id == id);
    if (_players.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _players.length) {
      _currentIndex = 0;
    }
  }

  void setPlayers(List<String> names) {
    _players
      ..clear();

    _nextId = 1;
    _currentIndex = 0;
    for (final rawName in names) {
      final name = rawName.trim();
      if (name.isEmpty) continue;
      _players.add(Player(id: _nextId++, name: name));
    }
  }

  Player? nextPlayer() {
    if (_players.isEmpty) return null;
    final player = _players[_currentIndex];
    _currentIndex = (_currentIndex + 1) % _players.length;
    return player;
  }
}
