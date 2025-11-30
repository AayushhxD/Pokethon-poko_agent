import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../models/pokeagent.dart';
import '../models/battle_models.dart';
import 'battle_result_screen.dart';

/// Flutter 3D Battle Screen using Transform and AnimatedBuilder
/// Pure Flutter implementation without Unity
class Flutter3DBattleScreen extends StatefulWidget {
  final PokeAgent myAgent;
  final BattleAgent opponentAgent;
  final int battleId;

  const Flutter3DBattleScreen({
    Key? key,
    required this.myAgent,
    required this.opponentAgent,
    required this.battleId,
  }) : super(key: key);

  @override
  State<Flutter3DBattleScreen> createState() => _Flutter3DBattleScreenState();
}

class _Flutter3DBattleScreenState extends State<Flutter3DBattleScreen>
    with TickerProviderStateMixin {
  // Battle state
  bool _battleStarted = false;
  bool _battleEnded = false;
  int _currentTurn = 0;
  double _playerHp = 1.0;
  double _opponentHp = 1.0;
  bool? _playerWon;

  // Interactive battle state
  bool _isAttacking = false;
  int? _selectedMoveIndex;
  String _battleMessage = '';

  // Animation controllers
  late AnimationController _playerAttackController;
  late AnimationController _opponentAttackController;
  late AnimationController _cameraShakeController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  // Battle log (kept for future analytics even if not shown)
  final List<String> _battleLog = [];
  // Move sets for different types
  final Map<String, List<Map<String, dynamic>>> _moveSets = {
    'fire': [
      {'name': '🔥 Flamethrower', 'power': 90},
      {'name': '💥 Fire Blast', 'power': 110},
      {'name': '✨ Ember', 'power': 40},
      {'name': '🌟 Fire Punch', 'power': 75},
    ],
    'water': [
      {'name': '💧 Hydro Pump', 'power': 110},
      {'name': '🌊 Surf', 'power': 90},
      {'name': '💦 Water Gun', 'power': 40},
      {'name': '🫧 Bubble Beam', 'power': 65},
    ],
    'grass': [
      {'name': '🌿 Solar Beam', 'power': 120},
      {'name': '🍃 Leaf Storm', 'power': 130},
      {'name': '🪴 Vine Whip', 'power': 45},
      {'name': '🌱 Energy Ball', 'power': 90},
    ],
    'electric': [
      {'name': '⚡ Thunder', 'power': 110},
      {'name': '💫 Thunderbolt', 'power': 90},
      {'name': '✨ Spark', 'power': 65},
      {'name': '🌩️ Thunder Wave', 'power': 40},
    ],
    'ice': [
      {'name': '❄️ Ice Beam', 'power': 90},
      {'name': '🧊 Blizzard', 'power': 110},
      {'name': '⛄ Ice Punch', 'power': 75},
      {'name': '🌨️ Frost Breath', 'power': 60},
    ],
    'psychic': [
      {'name': '🔮 Psychic', 'power': 90},
      {'name': '🌀 Psyshock', 'power': 80},
      {'name': '💭 Confusion', 'power': 50},
      {'name': '✨ Psybeam', 'power': 65},
    ],
    'dragon': [
      {'name': '🐉 Draco Meteor', 'power': 130},
      {'name': '💫 Dragon Pulse', 'power': 85},
      {'name': '🌊 Dragon Breath', 'power': 60},
      {'name': '⚡ Dragon Claw', 'power': 80},
    ],
    'fighting': [
      {'name': '👊 Close Combat', 'power': 120},
      {'name': '💪 Brick Break', 'power': 75},
      {'name': '✊ Karate Chop', 'power': 50},
      {'name': '🥊 Dynamic Punch', 'power': 100},
    ],
    'rock': [
      {'name': '🪨 Stone Edge', 'power': 100},
      {'name': '💎 Rock Slide', 'power': 75},
      {'name': '🌑 Rock Throw', 'power': 50},
      {'name': '⛰️ Power Gem', 'power': 80},
    ],
    'ground': [
      {'name': '🌍 Earthquake', 'power': 100},
      {'name': '💥 Earth Power', 'power': 90},
      {'name': '🏜️ Dig', 'power': 80},
      {'name': '🌪️ Sand Tomb', 'power': 35},
    ],
    'flying': [
      {'name': '🦅 Brave Bird', 'power': 120},
      {'name': '🌪️ Hurricane', 'power': 110},
      {'name': '💨 Air Slash', 'power': 75},
      {'name': '🪶 Wing Attack', 'power': 60},
    ],
    'bug': [
      {'name': '🦗 Bug Buzz', 'power': 90},
      {'name': '🐛 X-Scissor', 'power': 80},
      {'name': '🦟 Leech Life', 'power': 80},
      {'name': '🕷️ Signal Beam', 'power': 75},
    ],
    'poison': [
      {'name': '☠️ Sludge Bomb', 'power': 90},
      {'name': '🧪 Poison Jab', 'power': 80},
      {'name': '💜 Venoshock', 'power': 65},
      {'name': '🟣 Acid Spray', 'power': 40},
    ],
    'ghost': [
      {'name': '👻 Shadow Ball', 'power': 80},
      {'name': '🌑 Shadow Claw', 'power': 70},
      {'name': '💀 Night Shade', 'power': 60},
      {'name': '🕯️ Hex', 'power': 65},
    ],
    'dark': [
      {'name': '🌑 Dark Pulse', 'power': 80},
      {'name': '🗡️ Night Slash', 'power': 70},
      {'name': '💢 Crunch', 'power': 80},
      {'name': '🦹 Foul Play', 'power': 95},
    ],
    'steel': [
      {'name': '⚔️ Iron Head', 'power': 80},
      {'name': '🔩 Flash Cannon', 'power': 80},
      {'name': '⛓️ Metal Claw', 'power': 50},
      {'name': '🛡️ Steel Wing', 'power': 70},
    ],
    'fairy': [
      {'name': '🌸 Moonblast', 'power': 95},
      {'name': '✨ Dazzling Gleam', 'power': 80},
      {'name': '🧚 Play Rough', 'power': 90},
      {'name': '💫 Draining Kiss', 'power': 50},
    ],
    'normal': [
      {'name': '💪 Hyper Beam', 'power': 150},
      {'name': '👊 Giga Impact', 'power': 150},
      {'name': '✊ Tackle', 'power': 40},
      {'name': '💥 Body Slam', 'power': 85},
    ],
  };

  @override
  void initState() {
    super.initState();

    _playerAttackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opponentAttackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cameraShakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _floatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _addLog('⚔️ Battle Started!');
    _addLog('${widget.myAgent.name} vs ${widget.opponentAgent.name}');

    // Start battle after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _battleStarted = true);
      }
    });
  }

  @override
  void dispose() {
    _playerAttackController.dispose();
    _opponentAttackController.dispose();
    _cameraShakeController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _executeAttack(int moveIndex) async {
    if (_isAttacking || _battleEnded) return;

    final moves =
        _moveSets[widget.myAgent.type.toLowerCase()] ?? _moveSets['fire']!;
    final selectedMove = moves[moveIndex];

    setState(() {
      _selectedMoveIndex = moveIndex;
      _isAttacking = true;
      _battleMessage = 'You used ${selectedMove['name']}!';
      _currentTurn++;
    });

    _addLog('💥 You used ${selectedMove['name']}!');

    // Player attack animation
    await _playerAttackController.forward();
    await _playerAttackController.reverse();
    _cameraShakeController.forward(from: 0);

    // Calculate balanced damage
    final myAttack = widget.myAgent.stats['attack'] ?? 50;
    final movePower = selectedMove['power'] as int;
    final baseDamage = (movePower * myAttack / 200);
    final variance = math.Random().nextInt(30) - 15;
    final finalDamage = ((baseDamage + variance) / 100).clamp(0.05, 0.30);

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _opponentHp = (_opponentHp - finalDamage).clamp(0.0, 1.0);
    });

    _addLog('🎯 Dealt ${(finalDamage * 100).toInt()} damage!');

    await Future.delayed(const Duration(milliseconds: 800));

    // Check if battle ended
    if (_opponentHp <= 0) {
      _endBattle();
      return;
    }

    // Opponent attacks back
    final opponentMoves = _moveSets['water'] ?? _moveSets['fire']!;
    final oppMove = opponentMoves[math.Random().nextInt(opponentMoves.length)];

    setState(() {
      _battleMessage = '${widget.opponentAgent.name} used ${oppMove['name']}!';
    });

    _addLog('🔥 ${widget.opponentAgent.name} used ${oppMove['name']}!');

    await Future.delayed(const Duration(milliseconds: 500));

    // Opponent attack animation
    await _opponentAttackController.forward();
    await _opponentAttackController.reverse();
    _cameraShakeController.forward(from: 0);

    // Opponent damage (balanced)
    final oppPower = oppMove['power'] as int;
    final oppAttack = widget.opponentAgent.attack;
    final oppBaseDamage = (oppPower * oppAttack / 200);
    final oppVariance = math.Random().nextInt(30) - 15;
    final oppFinalDamage = ((oppBaseDamage + oppVariance) / 100).clamp(
      0.05,
      0.30,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _playerHp = (_playerHp - oppFinalDamage).clamp(0.0, 1.0);
    });

    _addLog('💔 Received ${(oppFinalDamage * 100).toInt()} damage!');

    await Future.delayed(const Duration(milliseconds: 800));

    // Check if battle ended
    if (_playerHp <= 0) {
      _endBattle();
      return;
    }

    setState(() {
      _isAttacking = false;
      _selectedMoveIndex = null;
      _battleMessage = '';
    });
  }

  void _endBattle() {
    setState(() {
      _battleEnded = true;
      _playerWon = _playerHp > _opponentHp;
    });
    _addLog(_playerWon! ? '🎉 Victory!' : '💀 Defeat!');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Create opponent PokeAgent for the result screen
        final opponentPokeAgent = PokeAgent(
          id: widget.opponentAgent.tokenId.toString(),
          name: widget.opponentAgent.name,
          type: widget.opponentAgent.elementType,
          imageUrl: widget.opponentAgent.imageUrl,
          xp: 0,
          evolutionStage: 1,
          personality: 'Aggressive',
          stats: {
            'hp': widget.opponentAgent.hp,
            'attack': widget.opponentAgent.attack,
            'defense': widget.opponentAgent.defense,
            'speed': widget.opponentAgent.speed,
          },
        );

        // Calculate rewards based on victory
        final coinsGained = _playerWon! ? 50 : 10;
        final expGained = _playerWon! ? 100 : 25;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => BattleResultScreen(
                  myPokeAgent: widget.myAgent,
                  opponentPokeAgent: opponentPokeAgent,
                  victory: _playerWon,
                  turns: _currentTurn,
                  expGained: expGained,
                  coinsGained: coinsGained,
                ),
          ),
        );
      }
    });
  }

  void _addLog(String message) {
    setState(() {
      _battleLog.add(message);
      if (_battleLog.length > 10) {
        _battleLog.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/battle_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if image not found
                return Container(
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
                );
              },
            ),
          ),
          // Dark overlay for better UI contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          // Animated particle background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: BattleParticlePainter(
                  animation: _particleController.value,
                  isAttacking: _isAttacking,
                ),
                size: Size.infinite,
              );
            },
          ),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: Stack(
                        children: [
                          _build3DBattleArena(),
                          if (_battleMessage.isNotEmpty) _buildBattleMessage(),
                        ],
                      ),
                    ),
                    if (_battleStarted && !_battleEnded) _buildAttackGrid(),
                  ],
                ),
                if (!_battleStarted) _buildLoadingOverlay(),
                if (_battleEnded) _buildBattleEndOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DBattleArena() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final spacing = math.max(12.0, availableHeight * 0.03);

        return AnimatedBuilder(
          animation: _cameraShakeController,
          builder: (context, child) {
            final shake =
                math.sin(_cameraShakeController.value * math.pi * 4) * 10;
            return Transform.translate(
              offset: Offset(shake, shake * 0.5),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _opponentAttackController,
                        builder: (context, child) {
                          final scale =
                              1.0 + (_opponentAttackController.value * 0.2);
                          return Transform(
                            transform:
                                Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(-0.3)
                                  ..scale(scale),
                            alignment: Alignment.center,
                            child: _buildPokemonWithFloating(
                              widget.opponentAgent.imageUrl,
                              widget.opponentAgent.name,
                              _opponentHp,
                              'Opponent',
                              const Color(0xFFFF6B35),
                              false,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // VS Badge in the middle of battle arena
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.3),
                              const Color(0xFFFFD700).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFFFD700,
                            ).withOpacity(0.4 + _glowAnimation.value * 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFFD700,
                              ).withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          'VS',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD700),
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFFD700),
                                blurRadius: 15,
                              ),
                              Shadow(color: Colors.orange, blurRadius: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: spacing),

                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _playerAttackController,
                        builder: (context, child) {
                          final scale =
                              1.0 + (_playerAttackController.value * 0.2);
                          return Transform(
                            transform:
                                Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(0.3)
                                  ..scale(scale),
                            alignment: Alignment.center,
                            child: _buildPokemonWithFloating(
                              widget.myAgent.imageUrl,
                              widget.myAgent.name,
                              _playerHp,
                              'You',
                              Color(
                                int.parse(
                                  '0xFF' +
                                      _getTypeColor(
                                        widget.myAgent.type,
                                      ).value.toRadixString(16).substring(2),
                                ),
                              ),
                              true,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPokemonWithFloating(
    String imageUrl,
    String name,
    double hp,
    String label,
    Color color,
    bool isPlayer,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _glowController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Player label with enhanced glow
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      color.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.3 + _glowAnimation.value * 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(_glowAnimation.value * 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlayer ? Icons.person : Icons.smart_toy,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(color: color.withOpacity(0.5), blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Pokemon model with enhanced glow
              _buildPokemon(imageUrl, name, color),
              const SizedBox(height: 8),
              // HP Bar
              _buildHPBar(label, hp, color),
            ],
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF6B35);
      case 'water':
        return const Color(0xFF4A90E2);
      case 'grass':
        return const Color(0xFF7AC74C);
      case 'electric':
        return const Color(0xFFF7D02C);
      default:
        return Colors.grey;
    }
  }

  Widget _buildPokemon(String imageUrl, String name, Color color) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Outer glow - pulsing
              BoxShadow(
                color: color.withOpacity(0.3 + _glowAnimation.value * 0.3),
                blurRadius: 25 + _glowAnimation.value * 10,
                spreadRadius: 5 + _glowAnimation.value * 5,
              ),
              // Inner glow
              BoxShadow(
                color: const Color(
                  0xFFFFD700,
                ).withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.5 + _glowAnimation.value * 0.3),
                width: 2,
              ),
              gradient: RadialGradient(
                colors: [color.withOpacity(0.2), Colors.black.withOpacity(0.6)],
              ),
            ),
            child: ClipOval(
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Center(
                              child: Icon(
                                Icons.catching_pokemon,
                                size: 50,
                                color: color,
                              ),
                            ),
                      )
                      : Center(
                        child: Icon(
                          Icons.catching_pokemon,
                          size: 50,
                          color: color,
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHPBar(String name, double hp, Color color) {
    final hpColor =
        hp > 0.5
            ? color
            : hp > 0.25
            ? const Color(0xFFFFB74D)
            : const Color(0xFFE53935);

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: hpColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(hp * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    color: hpColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
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
                          colors: [hpColor, hpColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: hpColor.withOpacity(
                              _glowController.value * 0.6,
                            ),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      const Color(0xFF1A0F08).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(
                      0xFFFFD700,
                    ).withOpacity(0.3 + _glowAnimation.value * 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFFFD700,
                      ).withOpacity(_glowAnimation.value * 0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: const Color(0xFFFFD700),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Battleground',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, color: const Color(0xFFFFD700), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Turn $_currentTurn',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleMessage() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.85),
                    const Color(0xFF1A0F08).withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(
                    0xFFFFD700,
                  ).withOpacity(0.4 + _glowAnimation.value * 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFFFD700,
                    ).withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFFFFD700),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _battleMessage,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttackGrid() {
    final moves =
        _moveSets[widget.myAgent.type.toLowerCase()] ?? _moveSets['fire']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF1A0F08).withOpacity(0.95),
            Colors.black.withOpacity(0.98),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: const Color(0xFFFFD700),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Choose Your Attack',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            itemCount: moves.length,
            itemBuilder: (context, index) {
              final move = moves[index];
              final isSelected = _selectedMoveIndex == index;
              final isEnabled = !_isAttacking;

              return _buildAttackButton(
                move['name'],
                move['power'],
                isSelected,
                isEnabled,
                () => _executeAttack(index),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttackButton(
    String moveName,
    int power,
    bool isSelected,
    bool isEnabled,
    VoidCallback onTap,
  ) {
    final powerColor =
        power >= 100
            ? const Color(0xFFFF4444)
            : power >= 70
            ? const Color(0xFFFFA500)
            : const Color(0xFF4A90E2);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isSelected
                        ? [
                          powerColor.withOpacity(0.4),
                          powerColor.withOpacity(0.2),
                        ]
                        : [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.3),
                        ],
              ),
              border: Border.all(
                color:
                    isSelected
                        ? powerColor.withOpacity(
                          0.6 + _glowController.value * 0.4,
                        )
                        : Colors.white.withOpacity(0.15),
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: powerColor.withOpacity(
                            _glowController.value * 0.5,
                          ),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          moveName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color:
                                isEnabled
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : powerColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.4)
                                    : powerColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$power',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : powerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    power >= 100
                        ? 'Very Strong'
                        : power >= 70
                        ? 'Strong'
                        : 'Normal',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color:
                          isEnabled
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final playerColor = _getTypeColor(widget.myAgent.type);
    final opponentColor = _getTypeColor(widget.opponentAgent.elementType);

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _floatController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                const Color(0xFF2A1810).withOpacity(0.95),
                const Color(0xFF1A0F08),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: const Color(0xFFFFD700),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Finding Match',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

                // Pokemon VS Section - Clean layout with VS in between
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Player Pokemon
                      Expanded(
                        child: Column(
                          children: [
                            // Label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: playerColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'YOU',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Pokemon Image
                            Transform.translate(
                              offset: Offset(0, _floatAnimation.value * 0.5),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      playerColor.withOpacity(0.4),
                                      playerColor.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: playerColor.withOpacity(
                                        _glowAnimation.value * 0.5,
                                      ),
                                      blurRadius: 25,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    widget.myAgent.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.catching_pokemon,
                                          size: 60,
                                          color: playerColor,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Name
                            Text(
                              widget.myAgent.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Type
                            Text(
                              widget.myAgent.type.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: playerColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // VS Badge in the middle
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.4),
                              const Color(0xFFFFD700).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFFD700,
                              ).withOpacity(_glowAnimation.value * 0.6),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          'VS',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD700),
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFFD700),
                                blurRadius: 15,
                              ),
                              Shadow(color: Colors.orange, blurRadius: 8),
                            ],
                          ),
                        ),
                      ),

                      // Opponent Pokemon
                      Expanded(
                        child: Column(
                          children: [
                            // Label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: opponentColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ENEMY',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Pokemon Image
                            Transform.translate(
                              offset: Offset(0, -_floatAnimation.value * 0.5),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      opponentColor.withOpacity(0.4),
                                      opponentColor.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: opponentColor.withOpacity(
                                        _glowAnimation.value * 0.5,
                                      ),
                                      blurRadius: 25,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    widget.opponentAgent.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.smart_toy,
                                          size: 60,
                                          color: opponentColor,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Name
                            Text(
                              widget.opponentAgent.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Type
                            Text(
                              widget.opponentAgent.elementType.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: opponentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Loading indicator
                Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: const Color(0xFFFFD700),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Preparing Battle Arena...',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Battle tips
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: const Color(0xFFFFD700),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tip: Choose your attacks wisely! Higher power moves deal more damage.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Animated dots
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.3;
                      final animValue = ((_glowAnimation.value + delay) % 1.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFFFFD700,
                          ).withOpacity(0.3 + animValue * 0.7),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFFD700,
                              ).withOpacity(animValue * 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBattleEndOverlay() {
    final isVictory = _playerWon!;
    final mainColor =
        isVictory ? const Color(0xFFFFD700) : const Color(0xFFE53935);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                mainColor.withOpacity(0.15),
                Colors.black.withOpacity(0.95),
                Colors.black,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        mainColor.withOpacity(0.3),
                        mainColor.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(
                          _glowAnimation.value * 0.5,
                        ),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    isVictory ? Icons.emoji_events : Icons.dangerous,
                    color: mainColor,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                // Victory/Defeat text with glow
                Text(
                  isVictory ? 'VICTORY!' : 'DEFEAT',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(color: mainColor.withOpacity(0.8), blurRadius: 20),
                      Shadow(color: mainColor.withOpacity(0.5), blurRadius: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  isVictory
                      ? 'Congratulations, Trainer!'
                      : 'Better luck next time!',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                // Continue button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mainColor, mainColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(
                            _glowAnimation.value * 0.5,
                          ),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.2)
          ..strokeWidth = 1;

    const gridSize = 10;
    for (int i = 0; i <= gridSize; i++) {
      final x = size.width * i / gridSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      final y = size.height * i / gridSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for animated battle particles
class BattleParticlePainter extends CustomPainter {
  final double animation;
  final bool isAttacking;

  BattleParticlePainter({required this.animation, required this.isAttacking});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    // Floating embers/particles
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height + random.nextDouble() * 100;
      final y = (baseY - (animation * 250 * (1 + i % 3))) % (size.height + 100);

      if (y > -20) {
        final radius = random.nextDouble() * 3 + 1;
        final opacity = (1 - (y / size.height)) * random.nextDouble() * 0.5;

        // Use orange/gold colors for battle theme
        paint.color =
            isAttacking
                ? Color.fromRGBO(255, 100, 50, opacity)
                : Color.fromRGBO(255, 180, 50, opacity);

        // Glow effect
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), radius * 2.5, paint);
        paint.maskFilter = null;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    // Sparkles/stars
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = (math.sin(animation * math.pi * 2 + i) + 1) / 2;

      paint.color = Colors.white.withOpacity(twinkle * 0.35);
      paint.strokeWidth = 1.5;

      final starSize = 3 + random.nextDouble() * 2;
      canvas.drawLine(Offset(x - starSize, y), Offset(x + starSize, y), paint);
      canvas.drawLine(Offset(x, y - starSize), Offset(x, y + starSize), paint);
    }

    // Additional glow orbs for battle intensity
    if (isAttacking) {
      for (int i = 0; i < 8; i++) {
        final x = size.width * 0.3 + random.nextDouble() * size.width * 0.4;
        final y = size.height * 0.3 + random.nextDouble() * size.height * 0.4;
        final pulse = (math.sin(animation * math.pi * 4 + i * 0.5) + 1) / 2;

        paint.color = const Color(0xFFFFD700).withOpacity(pulse * 0.3);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawCircle(Offset(x, y), 10 + pulse * 5, paint);
        paint.maskFilter = null;
      }
    }
  }

  @override
  bool shouldRepaint(BattleParticlePainter oldDelegate) => true;
}
