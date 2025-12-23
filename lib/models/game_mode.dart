import 'package:flutter/material.dart';

enum GameModeId {
  classic,
  quick,
  blackjack,
  spanishDuel,
  touchSelector,
  yoNunca,
  duel,
  juez,
  bomb,
  thoughtYouWouldntSay,
  mirror,
  drunkMath,
  sacrificado,
  multas,
  horseRace,
  favorite,
  openMic,
  falseMemory,
  mole,
  vampire,
  secretRoles,
}

class GameMode {
  final GameModeId id;
  final String title;
  final String description;
  final IconData icon;
  final Color? primaryColor;
  final Color? accentColor;

  const GameMode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.primaryColor,
    this.accentColor,
  });
}
