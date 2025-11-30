import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../models/pokeagent.dart';
import '../models/battle_models.dart';

class BattleResultScreen extends StatefulWidget {
  // Legacy support for old calls
  final BattleResult? battleResult;
  final BattleAgent? myAgent;
  final BattleAgent? opponent;

  // New simple parameters
  final PokeAgent? myPokeAgent;
  final PokeAgent? opponentPokeAgent;
  final bool? victory;
  final int? turns;
  final int? expGained;
  final int? coinsGained;

  const BattleResultScreen({
    Key? key,
    this.battleResult,
    this.myAgent,
    this.opponent,
    this.myPokeAgent,
    this.opponentPokeAgent,
    this.victory,
    this.turns,
    this.expGained,
    this.coinsGained,
  }) : super(key: key);

  @override
  State<BattleResultScreen> createState() => _BattleResultScreenState();
}

class _BattleResultScreenState extends State<BattleResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = widget.victory ?? widget.battleResult?.isWinner ?? false;

    if (widget.myPokeAgent != null && widget.opponentPokeAgent != null) {
      return _buildNewResultScreen(isWinner);
    }

    return _buildLegacyFallback();
  }

  Widget _buildNewResultScreen(bool isWinner) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(0xFF2A1810),
              const Color(0xFF1A0F08),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particle background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BattlegroundParticlePainter(
                    animation: _particleController.value,
                    isVictory: isWinner,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildBattlegroundTitle(isWinner),
                            const SizedBox(height: 40),
                            _buildPokemonBattle(isWinner),
                            const SizedBox(height: 40),
                            _buildRewardsSection(isWinner),
                            const SizedBox(height: 30),
                            _buildActionButtons(),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Color(0xFFFFD700), size: 18),
                SizedBox(width: 6),
                Text(
                  'Connected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattlegroundTitle(bool isWinner) {
    return Column(
      children: [
        Text(
          'Battleground',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isWinner
                  ? [
                      const Color(0xFFFFD700).withOpacity(0.3),
                      const Color(0xFFFFA500).withOpacity(0.2),
                    ]
                  : [
                      const Color(0xFFFF4444).withOpacity(0.3),
                      const Color(0xFFCC0000).withOpacity(0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWinner
                  ? const Color(0xFFFFD700).withOpacity(0.5)
                  : const Color(0xFFFF4444).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Text(
            isWinner ? '⭐ VICTORY ⭐' : '💀 DEFEAT 💀',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWinner ? const Color(0xFFFFD700) : const Color(0xFFFF4444),
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonBattle(bool isWinner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Pokemon Battle Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPokemonCard(
                widget.opponentPokeAgent!,
                'Player 1',
                !isWinner,
              ),
              Column(
                children: [
                  Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.flash_on,
                    color: Color(0xFFFFD700),
                    size: 28,
                  ),
                ],
              ),
              _buildPokemonCard(
                widget.myPokeAgent!,
                'You',
                isWinner,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // HP Bars
          _buildHPBars(isWinner),
        ],
      ),
    );
  }

  Widget _buildPokemonCard(PokeAgent agent, String label, bool isWinner) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Column(
            children: [
              // Pokemon Image with glow
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isWinner
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withOpacity(_glowAnimation.value * 0.6),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: agent.imageUrl.isNotEmpty
                            ? Image.network(
                                agent.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    agent.moodEmoji,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  agent.moodEmoji,
                                  style: const TextStyle(fontSize: 60),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Player label with avatar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        label == 'You' ? Icons.person : Icons.computer,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHPBars(bool isWinner) {
    final myHP = isWinner ? 0.7 : 0.2;
    final oppHP = isWinner ? 0.1 : 0.6;

    return Column(
      children: [
        _buildSingleHPBar('Player 1', oppHP, Colors.blue),
        const SizedBox(height: 12),
        _buildSingleHPBar('You', myHP, const Color(0xFFFFA500)),
      ],
    );
  }

  Widget _buildSingleHPBar(String label, double hp, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(hp * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: hp,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardsSection(bool isWinner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A0F08).withOpacity(0.9),
            const Color(0xFF2A1810).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // NFT Badge
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'NFT REWARDS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 6),
                Text(
                  'Blockchain Verified',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Reward Cards
          Row(
            children: [
              Expanded(
                child: _buildRewardCard(
                  '💎',
                  'POKO Tokens',
                  '+${widget.coinsGained ?? 0}',
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRewardCard(
                  '⚡',
                  'Experience',
                  '+${widget.expGained ?? 0} XP',
                  const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(String emoji, String label, String value, Color color) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              'Home',
              Icons.home,
              Colors.white.withOpacity(0.1),
              Colors.white,
              () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildButton(
              'New Battle',
              Icons.sports_mma,
              const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              Colors.white,
              () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, dynamic background,
      Color textColor, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: background is LinearGradient ? background : null,
        color: background is Color ? background : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: background is LinearGradient
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyFallback() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Battle Result'),
      ),
      body: Center(
        child: Text(
          'Legacy mode - use new parameters',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// Custom painter for battleground particles
class BattlegroundParticlePainter extends CustomPainter {
  final double animation;
  final bool isVictory;

  BattlegroundParticlePainter({
    required this.animation,
    required this.isVictory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    // Floating embers/particles
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height + random.nextDouble() * 100;
      final y = (baseY - (animation * 200 * (1 + i % 3))) % (size.height + 100);
      
      if (y > -20) {
        final radius = random.nextDouble() * 3 + 1;
        final opacity = (1 - (y / size.height)) * random.nextDouble() * 0.6;

        paint.color = isVictory
            ? Color.fromRGBO(255, 215, 0, opacity)
            : Color.fromRGBO(255, 140, 0, opacity);

        // Glow effect
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(x, y), radius * 2, paint);
        paint.maskFilter = null;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    // Sparkles
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = (math.sin(animation * math.pi * 2 + i) + 1) / 2;
      
      paint.color = Colors.white.withOpacity(twinkle * 0.4);
      paint.strokeWidth = 1.5;
      
      final size_ = 3 + random.nextDouble() * 2;
      canvas.drawLine(
        Offset(x - size_, y),
        Offset(x + size_, y),
        paint,
      );
      canvas.drawLine(
        Offset(x, y - size_),
        Offset(x, y + size_),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BattlegroundParticlePainter oldDelegate) => true;
}
