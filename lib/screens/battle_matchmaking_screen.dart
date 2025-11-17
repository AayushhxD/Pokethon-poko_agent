import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokeagent.dart';
import '../utils/theme.dart';
import 'battle_arena_screen.dart';

class BattleMatchmakingScreen extends StatefulWidget {
  final PokeAgent selectedAgent;

  const BattleMatchmakingScreen({super.key, required this.selectedAgent});

  @override
  State<BattleMatchmakingScreen> createState() =>
      _BattleMatchmakingScreenState();
}

class _BattleMatchmakingScreenState extends State<BattleMatchmakingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _spinController;
  bool _isMatchmaking = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _startMatchmaking();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _startMatchmaking() async {
    // Simulate matchmaking progress
    for (int i = 0; i <= 100; i++) {
      if (!mounted) return;

      setState(() {
        _progress = i / 100;
      });

      await Future.delayed(const Duration(milliseconds: 50));

      if (i == 85) {
        // Found opponent
        setState(() {
          _isMatchmaking = false;
        });

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => BattleArenaScreen(
                  playerAgent: widget.selectedAgent,
                  opponentAgent: _createOpponentAgent(),
                ),
          ),
        );
        return;
      }
    }
  }

  PokeAgent _createOpponentAgent() {
    // Create a random opponent for demo
    final opponents = [
      {'name': 'Charizard', 'type': 'Fire'},
      {'name': 'Blastoise', 'type': 'Water'},
      {'name': 'Venusaur', 'type': 'Grass'},
      {'name': 'Pikachu', 'type': 'Electric'},
    ];

    final randomOpponent =
        opponents[DateTime.now().millisecondsSinceEpoch % opponents.length];

    return PokeAgent(
      id: 'opponent_${DateTime.now().millisecondsSinceEpoch}',
      name: randomOpponent['name']!,
      type: randomOpponent['type']!,
      imageUrl: '',
      xp: 500,
      evolutionStage: 1,
      personality: 'aggressive',
      mood: 'focused',
      moodLevel: 80,
      isFavorite: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child:
                    _isMatchmaking
                        ? _buildMatchmakingView()
                        : _buildFoundOpponentView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: _cancelMatchmaking,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'Finding Opponent',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchmakingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated creatures
          FadeIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedCreature(widget.selectedAgent, false),
                const SizedBox(width: 40),
                AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spinController.value * 2 * 3.14159,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 40),
                _buildAnimatedCreature(null, true), // Placeholder for opponent
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Progress bar
          Container(
            width: 250,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Searching for opponent...',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 40),

          // Ranking info
          _buildRankingCard(),

          const SizedBox(height: 40),

          // Cancel button
          ElevatedButton(
            onPressed: _cancelMatchmaking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: const BorderSide(color: Colors.red, width: 1),
              ),
            ),
            child: Text(
              'Cancel Matchmaking',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundOpponentView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ZoomIn(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.2),
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
          ),

          const SizedBox(height: 24),

          FadeInUp(
            child: Text(
              'Opponent Found!',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Preparing battle arena...',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCreature(PokeAgent? agent, bool isOpponent) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  agent != null
                      ? AppTheme.getTypeColor(agent.type).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
              border: Border.all(
                color:
                    agent != null
                        ? AppTheme.getTypeColor(agent.type)
                        : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.catching_pokemon,
              color:
                  agent != null
                      ? AppTheme.getTypeColor(agent.type)
                      : Colors.white54,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankingCard() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              'Your Ranking',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRankingStat('ELO', '1,250', Colors.blue),
                _buildRankingStat('Wins', '24', Colors.green),
                _buildRankingStat('Losses', '8', Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+12 FRT tokens available',
                    style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _cancelMatchmaking() {
    Navigator.pop(context);
  }
}
