import '../models/night_dna_stats.dart';

class NightDnaService {
  NightDnaService._internal();
  static final NightDnaService _instance = NightDnaService._internal();
  factory NightDnaService() => _instance;

  final Map<int, NightDnaStats> _stats = {};

  void resetSession() {
    _stats.clear();
  }

  void ensurePlayer(int playerId) {
    _stats.putIfAbsent(playerId, () => NightDnaStats());
  }

  void addDrink(int playerId, {int amount = 1}) {
    ensurePlayer(playerId);
    _stats[playerId]!.drinksTaken += amount;
  }

  void addWin(int playerId) {
    ensurePlayer(playerId);
    _stats[playerId]!.wins += 1;
  }

  void addLoss(int playerId) {
    ensurePlayer(playerId);
    _stats[playerId]!.losses += 1;
  }

  void addPunishmentGiven(int playerId, {int amount = 1}) {
    ensurePlayer(playerId);
    _stats[playerId]!.punishmentsGiven += amount;
  }

  int drinks(int playerId) {
    return _stats[playerId]?.drinksTaken ?? 0;
  }

  int wins(int playerId) {
    return _stats[playerId]?.wins ?? 0;
  }

  int losses(int playerId) {
    return _stats[playerId]?.losses ?? 0;
  }

  int punishmentsGiven(int playerId) {
    return _stats[playerId]?.punishmentsGiven ?? 0;
  }

  int dominanceScore(int playerId) {
    return _stats[playerId]?.dominanceScore ?? 0;
  }

  int getDominantPlayerId() {
    if (_stats.isEmpty) return -1;
    return _stats.entries
        .reduce((a, b) =>
            a.value.dominanceScore >= b.value.dominanceScore ? a : b)
        .key;
  }

  int getMostPunishedPlayerId() {
    if (_stats.isEmpty) return -1;
    return _stats.entries
        .reduce((a, b) =>
            a.value.drinksTaken >= b.value.drinksTaken ? a : b)
        .key;
  }

  int getMostSavedPlayerId() {
    if (_stats.isEmpty) return -1;
    return _stats.entries
        .reduce((a, b) =>
            a.value.drinksTaken <= b.value.drinksTaken ? a : b)
        .key;
  }

  int getBalancedTargetPlayerId() {
    if (_stats.isEmpty) return -1;
    final dominant = getDominantPlayerId();
    if (dominant != -1 && dominanceScore(dominant) > 0) {
      return dominant;
    }
    return getMostSavedPlayerId();
  }

  List<int> rankByDrinksDesc() {
    final entries = List<MapEntry<int, NightDnaStats>>.from(_stats.entries);
    entries.sort((a, b) => b.value.drinksTaken.compareTo(a.value.drinksTaken));
    return entries.map((e) => e.key).toList();
  }

  List<int> rankByDominanceDesc() {
    final entries = List<MapEntry<int, NightDnaStats>>.from(_stats.entries);
    entries
        .sort((a, b) => b.value.dominanceScore.compareTo(a.value.dominanceScore));
    return entries.map((e) => e.key).toList();
  }
}
