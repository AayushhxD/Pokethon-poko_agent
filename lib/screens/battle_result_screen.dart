import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokeagent.dart';
import '../utils/theme.dart';
import 'battle_lobby_screen.dart';
import 'battle_arena_screen.dart';

class BattleResultScreen extends StatefulWidget {
  final String winner;
  final PokeAgent playerAgent;
  final PokeAgent opponentAgent;
  final bool isPlayerWinner;

  const BattleResultScreen({
    super.key,
    required this.winner,
    required this.playerAgent,
    required this.opponentAgent,
    required this.isPlayerWinner,
  });

  @override
  State<BattleResultScreen> createState() => _BattleResultScreenState();
}

class _BattleResultScreenState extends State<BattleResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _xpBarController;
  double _xpProgress = 0.0;
  int _tokensEarned = 0;

  @override
  void initState() {
    super.initState();
    _xpBarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _tokensEarned = widget.isPlayerWinner ? 25 : 10;

    // Animate XP bar
    Future.delayed(const Duration(milliseconds: 500), () {
      _xpBarController.forward();
      setState(() {
        _xpProgress = widget.isPlayerWinner ? 0.75 : 0.25; // Simulate XP gain
      });
    });
  }

  @override
  void dispose() {
    _xpBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultBadge(),
                  const SizedBox(height: 40),
                  _buildResultDetails(),
                  const SizedBox(height: 40),
                  _buildRewardsSection(),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultBadge() {
    return ZoomIn(
      duration: const Duration(seconds: 1),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors:
                widget.isPlayerWinner
                    ? [Colors.yellow.shade400, Colors.orange.shade500]
                    : [Colors.grey.shade400, Colors.grey.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isPlayerWinner ? Colors.yellow : Colors.grey)
                  .withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isPlayerWinner ? Icons.emoji_events : Icons.handshake,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              widget.isPlayerWinner ? 'VICTORY!' : 'DEFEAT',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDetails() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              'Battle Summary',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Winner announcement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    widget.isPlayerWinner
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isPlayerWinner ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isPlayerWinner ? Icons.emoji_events : Icons.close,
                    color: widget.isPlayerWinner ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.winner} Wins!',
                    style: GoogleFonts.poppins(
                      color: widget.isPlayerWinner ? Colors.green : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Creatures comparison
            Row(
              children: [
                Expanded(
                  child: _buildCreatureResult(
                    widget.playerAgent,
                    widget.isPlayerWinner,
                  ),
                ),
                Container(
                  width: 40,
                  height: 2,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildCreatureResult(
                    widget.opponentAgent,
                    !widget.isPlayerWinner,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatureResult(PokeAgent agent, bool isWinner) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.getTypeColor(agent.type).withOpacity(0.3),
            border: Border.all(
              color:
                  isWinner ? Colors.yellow : AppTheme.getTypeColor(agent.type),
              width: isWinner ? 3 : 2,
            ),
          ),
          child: const Icon(
            Icons.catching_pokemon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          agent.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          'Lv.${agent.level}',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        if (isWinner) ...[
          const SizedBox(height: 4),
          Icon(Icons.star, color: Colors.yellow, size: 16),
        ],
      ],
    );
  }

  Widget _buildRewardsSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 700),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              'Rewards Earned',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Tokens earned
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '+$_tokensEarned FRT Tokens',
                    style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // XP Progress
            Text(
              'Experience Points',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _xpBarController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _xpBarController.value * _xpProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '+${widget.isPlayerWinner ? 50 : 25} XP',
              style: GoogleFonts.poppins(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeInUp(
      delay: const Duration(milliseconds: 900),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _rematch,
              icon: const Icon(Icons.replay),
              label: const Text('Rematch'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _backToLobby,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back to Lobby'),
            ),
          ),
        ],
      ),
    );
  }

  void _rematch() {
    // Create new opponent for rematch
    final opponents = [
      {'name': 'Blastoise', 'type': 'Water'},
      {'name': 'Venusaur', 'type': 'Grass'},
      {'name': 'Charizard', 'type': 'Fire'},
      {'name': 'Pikachu', 'type': 'Electric'},
    ];

    final randomOpponent =
        opponents[DateTime.now().millisecondsSinceEpoch % opponents.length];

    final newOpponent = PokeAgent(
      id: 'rematch_${DateTime.now().millisecondsSinceEpoch}',
      name: randomOpponent['name']!,
      type: randomOpponent['type']!,
      imageUrl: '',
      xp: 600,
      evolutionStage: 1,
      personality: 'aggressive',
      mood: 'focused',
      moodLevel: 85,
      isFavorite: false,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => BattleArenaScreen(
              playerAgent: widget.playerAgent,
              opponentAgent: newOpponent,
            ),
      ),
    );
  }

  void _backToLobby() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (context) => BattleLobbyScreen(
              selectedAgent: widget.playerAgent,
              onAgentChanged: (agent) {
                // Handle agent change if needed
              },
            ),
      ),
      (route) => route.isFirst,
    );
  }
}
