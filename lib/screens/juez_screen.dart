import 'dart:math';

import 'package:flutter/material.dart';

import '../data/judge_phrases.dart';
import '../models/player.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';
import 'player_setup_screen.dart';

class JuezScreen extends StatefulWidget {
  const JuezScreen({super.key});

  @override
  State<JuezScreen> createState() => _JuezScreenState();
}

class _JuezScreenState extends State<JuezScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  late List<Player> _players;
  List<String> _remainingPhrases = [];
  String _currentPrompt = '';
  Map<int, int> _votesByPlayerId = {};
  int _votesCast = 0;

  @override
  void initState() {
    super.initState();
    _players = List<Player>.from(_playerService.players);
    _resetPhrases();
    _takeNextPrompt();
  }

  int get _requiredVotes => _players.length;
  bool get _hasEnoughPlayers => _players.length >= 2;
  bool get _votingFinished => _requiredVotes > 0 && _votesCast >= _requiredVotes;

  void _resetPhrases() {
    _remainingPhrases = List<String>.from(judgePhrases)..shuffle(_random);
  }

  void _takeNextPrompt() {
    if (_remainingPhrases.isEmpty) {
      _resetPhrases();
    }
    _currentPrompt = _remainingPhrases.removeAt(0);
  }

  void _resetVotes() {
    _votesByPlayerId = {};
    _votesCast = 0;
  }

  void _registerVote(Player player) {
    if (!_hasEnoughPlayers || _votingFinished) return;

    setState(() {
      _votesByPlayerId[player.id] = (_votesByPlayerId[player.id] ?? 0) + 1;
      _votesCast++;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Voto registrado ✅')));
  }

  List<int> get _topVotedPlayerIds {
    if (_votesByPlayerId.isEmpty) return [];
    final int maxVotes = _votesByPlayerId.values.reduce(max);
    return _votesByPlayerId.entries
        .where((entry) => entry.value == maxVotes)
        .map((entry) => entry.key)
        .toList();
  }

  String _playerNameById(int id) {
    final player = _players.firstWhere(
      (p) => p.id == id,
      orElse: () => Player(id: id, name: 'Jugador $id'),
    );
    return player.name;
  }

  String get _resultText {
    final winners = _topVotedPlayerIds.map(_playerNameById).toList();
    if (winners.isEmpty) {
      return 'Aún no hay votos';
    }
    if (winners.length == 1) {
      return '${winners.first} bebe 🍺';
    }
    final String names = winners.join(' y ');
    return 'Empate: $names beben 🍺🍺';
  }

  void _nextRound() {
    setState(() {
      _takeNextPrompt();
      _resetVotes();
    });
  }

  Future<void> _openPlayerSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlayerSetupScreen()),
    );
    setState(() {
      _players = List<Player>.from(_playerService.players);
      _resetVotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El Juez ⚖️',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Vota al culpable',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0318),
              Color(0xFF210721),
              Color(0xFF0E1B36),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_hasEnoughPlayers) ...[
                  _PromptCard(prompt: _currentPrompt),
                  const SizedBox(height: 12),
                  Text(
                    'Votos: $_votesCast / $_requiredVotes',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _buildPlayersGrid()),
                  const SizedBox(height: 12),
                  if (_votingFinished) _ResultCard(text: _resultText),
                ] else
                  Expanded(
                    child: _NoPlayersCard(onSetupPressed: _openPlayerSetup),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _votingFinished ? _nextRound : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Siguiente ronda',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const FiestaBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
        return GridView.builder(
          itemCount: _players.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final player = _players[index];
            final votes = _votesByPlayerId[player.id] ?? 0;
            final bool isWinner =
                _votingFinished && _topVotedPlayerIds.contains(player.id);
            return _PlayerVoteCard(
              player: player,
              votes: votes,
              showVotes: _votingFinished,
              isWinner: isWinner,
              onTap: () => _registerVote(player),
              enabled: !_votingFinished,
            );
          },
        );
      },
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String prompt;

  const _PromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pregunta',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            prompt,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlayerVoteCard extends StatelessWidget {
  final Player player;
  final int votes;
  final bool showVotes;
  final bool isWinner;
  final bool enabled;
  final VoidCallback onTap;

  const _PlayerVoteCard({
    required this.player,
    required this.votes,
    required this.showVotes,
    required this.isWinner,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final Color startColor = isWinner ? AppTheme.accent : const Color(0xFF2B1647);
    final Color endColor = isWinner ? AppTheme.primary : const Color(0xFF141026);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.8,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor.withOpacity(0.85), endColor.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: endColor.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (showVotes) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.how_to_vote_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$votes voto${votes == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  if (isWinner) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Text(
                        'GANA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String text;

  const _ResultCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoPlayersCard extends StatelessWidget {
  final VoidCallback onSetupPressed;

  const _NoPlayersCard({required this.onSetupPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_add_rounded, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              'Configura jugadores para jugar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Necesitas al menos 2 jugadores para votar.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: 'Configurar jugadores',
              icon: Icons.settings_rounded,
              onPressed: onSetupPressed,
            ),
          ],
        ),
      ),
    );
  }
}
