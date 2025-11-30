import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../models/pokeagent.dart';
import '../models/battle_models.dart';
import 'battle_result_screen.dart';

class InteractiveBattleScreen extends StatefulWidget {
  final PokeAgent myAgent;
  final BattleAgent opponentAgent;
  final int battleId;

  const InteractiveBattleScreen({
    Key? key,
    required this.myAgent,
    required this.opponentAgent,
    required this.battleId,
  }) : super(key: key);

  @override
  State<InteractiveBattleScreen> createState() =>
      _InteractiveBattleScreenState();
}

class _InteractiveBattleScreenState extends State<InteractiveBattleScreen>
    with TickerProviderStateMixin {
  // Battle state
  bool _battleStarted = false;
  bool _battleEnded = false;
  int _currentTurn = 0;
  bool _isPlayerTurn = true;
  int _lastDamage = 0;
  double _playerHp = 1.0;
  double _opponentHp = 1.0;
  bool? _playerWon;
  bool _waitingForMove = false;
  String _battleMessage = '';

  // Animation controllers
  late AnimationController _playerAttackController;
  late AnimationController _opponentAttackController;
  late AnimationController _cameraShakeController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  // Battle log
  final List<String> _battleLog = [];
  final ScrollController _logController = ScrollController();

  // Move sets for different types
  final Map<String, List<Map<String, dynamic>>> _moveSets = {
    'Fire': [
      {'name': '🔥 Flamethrower', 'power': 85, 'color': Colors.deepOrange},
      {'name': '💥 Fire Blast', 'power': 110, 'color': Colors.red},
      {'name': '✨ Ember', 'power': 60, 'color': Colors.orange},
      {'name': '🌟 Fire Punch', 'power': 75, 'color': Colors.redAccent},
    ],
    'Water': [
      {'name': '💧 Hydro Pump', 'power': 110, 'color': Colors.blue},
      {'name': '🌊 Surf', 'power': 90, 'color': Colors.lightBlue},
      {'name': '💦 Water Gun', 'power': 60, 'color': Colors.cyan},
      {'name': '🫧 Bubble Beam', 'power': 75, 'color': Colors.teal},
    ],
    'Grass': [
      {'name': '🌿 Solar Beam', 'power': 120, 'color': Colors.green},
      {'name': '🍃 Leaf Storm', 'power': 100, 'color': Colors.lightGreen},
      {'name': '🪴 Vine Whip', 'power': 65, 'color': Colors.greenAccent},
      {'name': '🌱 Energy Ball', 'power': 90, 'color': Colors.lime},
    ],
    'Electric': [
      {'name': '⚡ Thunder', 'power': 110, 'color': Colors.yellow},
      {'name': '💫 Thunderbolt', 'power': 90, 'color': Colors.amber},
      {'name': '✨ Spark', 'power': 65, 'color': Colors.yellowAccent},
      {'name': '🌩️ Thunder Wave', 'power': 75, 'color': Colors.orangeAccent},
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

    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _startBattle();
  }

  @override
  void dispose() {
    _playerAttackController.dispose();
    _opponentAttackController.dispose();
    _cameraShakeController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _logController.dispose();
    super.dispose();
  }

  void _startBattle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _battleStarted = true;
      _isPlayerTurn = true;
      _waitingForMove = true;
      _battleMessage = '⚔️ Your turn! Choose your move!';
    });
    _addLog('⚔️ Battle Started!');
  }

  Future<void> _executePlayerMove(Map<String, dynamic> move) async {
    if (!_waitingForMove || !_isPlayerTurn) return;

    setState(() {
      _waitingForMove = false;
      // Calculate damage based on stats and random variance
      final playerAttack = widget.myAgent.stats['attack'] ?? 50;
      final opponentDefense = widget.opponentAgent.defense;
      final baseDamage =
          (move['power'] * playerAttack / opponentDefense).toInt();
      final variance = math.Random().nextInt(20) - 10;
      _lastDamage = (baseDamage + variance).clamp(10, 150);
      _battleMessage = 'You used ${move['name']}!';
    });

    _addLog('💥 You used ${move['name']}! ($_lastDamage damage)');

    await _playerAttackController.forward();
    await _playerAttackController.reverse();

    _opponentHp = (_opponentHp - (_lastDamage / 200)).clamp(0.0, 1.0);
    _cameraShakeController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 800));

    if (_opponentHp <= 0) {
      _endBattle();
      return;
    }

    _currentTurn++;
    setState(() {
      _isPlayerTurn = false;
      _battleMessage = 'Opponent is attacking...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    _executeOpponentMove();
  }

  Future<void> _executeOpponentMove() async {
    final opponentMoves =
        _moveSets[widget.opponentAgent.elementType] ?? _moveSets['Water']!;
    final move = opponentMoves[math.Random().nextInt(opponentMoves.length)];

    setState(() {
      // Opponent damage calculation - can be stronger!
      final opponentAttack = widget.opponentAgent.attack;
      final playerDefense = widget.myAgent.stats['defense'] ?? 50;
      final baseDamage =
          (move['power'] * opponentAttack / playerDefense).toInt();
      final variance =
          math.Random().nextInt(25) - 5; // Opponent has slight advantage
      _lastDamage = (baseDamage + variance).clamp(10, 180);
      _battleMessage = 'Opponent used ${move['name']}!';
    });

    _addLog('🔥 Opponent used ${move['name']}! ($_lastDamage damage)');

    await _opponentAttackController.forward();
    await _opponentAttackController.reverse();

    _playerHp = (_playerHp - (_lastDamage / 200)).clamp(0.0, 1.0);
    _cameraShakeController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 800));

    if (_playerHp <= 0) {
      _endBattle();
      return;
    }

    _currentTurn++;
    setState(() {
      _isPlayerTurn = true;
      _waitingForMove = true;
      _battleMessage = '⚔️ Your turn! Choose your move!';
    });
  }

  void _endBattle() {
    setState(() {
      _battleEnded = true;
      _playerWon = _playerHp > _opponentHp;
      _battleMessage = _playerWon! ? '🎉 Victory!' : '💀 Defeat!';
    });
    _addLog(_playerWon! ? '🎉 Victory!' : '💀 Defeat!');

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => BattleResultScreen(
                  myPokeAgent: widget.myAgent,
                  opponentPokeAgent: PokeAgent(
                    id: widget.opponentAgent.tokenId.toString(),
                    name: widget.opponentAgent.name,
                    type: widget.opponentAgent.elementType,
                    imageUrl: widget.opponentAgent.imageUrl,
                    stats: {
                      'attack': widget.opponentAgent.attack,
                      'defense': widget.opponentAgent.defense,
                      'speed': widget.opponentAgent.speed,
                      'hp': widget.opponentAgent.hp,
                    },
                  ),
                  victory: _playerWon!,
                  turns: _currentTurn,
                  expGained:
                      _playerWon!
                          ? (100 + (widget.opponentAgent.level * 10))
                          : 20,
                  coinsGained:
                      _playerWon!
                          ? (50 + (widget.opponentAgent.level * 5))
                          : 10,
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

    Future.delayed(const Duration(milliseconds: 50), () {
      if (_logController.hasClients) {
        _logController.animateTo(
          _logController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        math.sin(_rotationController.value * 2 * math.pi) * 0.3,
                        math.cos(_rotationController.value * 2 * math.pi) * 0.3,
                      ),
                      colors: [
                        Colors.purple.shade900,
                        Colors.blue.shade900,
                        Colors.black,
                      ],
                    ),
                  ),
                );
              },
            ),

            // 3D Battle Arena
            AnimatedBuilder(
              animation: _cameraShakeController,
              builder: (context, child) {
                final shake =
                    math.sin(_cameraShakeController.value * math.pi * 4) * 10;
                return Transform.translate(
                  offset: Offset(shake, shake * 0.5),
                  child: child,
                );
              },
              child: _build3DBattleArena(),
            ),

            // UI Overlay
            Column(
              children: [
                _buildTopHUD(),
                const Spacer(),
                if (_battleStarted && !_battleEnded) _buildMoveSelection(),
                _buildBattleLog(),
              ],
            ),

            // Loading indicator
            if (!_battleStarted)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.cyan),
                      const SizedBox(height: 16),
                      Text(
                        'Preparing Battle Arena...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Battle End Overlay
            if (_battleEnded)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _playerWon! ? Icons.emoji_events : Icons.close,
                        color: _playerWon! ? Colors.amber : Colors.red,
                        size: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _playerWon! ? 'VICTORY!' : 'DEFEAT',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_playerWon!)
                        Text(
                          '+100 POKO Tokens',
                          style: GoogleFonts.poppins(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // Battle Message Overlay
            if (_battleMessage.isNotEmpty && !_battleEnded)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.purple.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.cyan.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _battleMessage,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _build3DBattleArena() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Opponent Pokemon
          AnimatedBuilder(
            animation: _opponentAttackController,
            builder: (context, child) {
              final scale = 1.0 + (_opponentAttackController.value * 0.3);
              return Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(-0.3)
                      ..scale(scale),
                alignment: Alignment.center,
                child: _buildPokemon(
                  widget.opponentAgent.imageUrl,
                  widget.opponentAgent.name,
                  _opponentHp,
                  false,
                ),
              );
            },
          ),

          const SizedBox(height: 80),

          // Battle Floor
          Transform(
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(1.2),
            alignment: Alignment.center,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withOpacity(0.3),
                    Colors.purple.withOpacity(0.3),
                  ],
                ),
                border: Border.all(
                  color: Colors.cyan.withOpacity(0.6),
                  width: 3,
                ),
              ),
              child: CustomPaint(painter: GridPainter()),
            ),
          ),

          const SizedBox(height: 80),

          // Player Pokemon
          AnimatedBuilder(
            animation: _playerAttackController,
            builder: (context, child) {
              final scale = 1.0 + (_playerAttackController.value * 0.3);
              return Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(0.3)
                      ..scale(scale),
                alignment: Alignment.center,
                child: _buildPokemon(
                  widget.myAgent.imageUrl,
                  widget.myAgent.name,
                  _playerHp,
                  true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPokemon(String imageUrl, String name, double hp, bool isPlayer) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPlayer ? Colors.blue : Colors.red).withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade800,
                  child: Icon(
                    Icons.catching_pokemon,
                    size: 80,
                    color: isPlayer ? Colors.blue : Colors.red,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHUD() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.purple.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Turn $_currentTurn',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isPlayerTurn ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isPlayerTurn ? 'YOUR TURN' : 'OPPONENT',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHPBar('Opponent', _opponentHp, Colors.red),
          const SizedBox(height: 12),
          _buildHPBar(widget.myAgent.name, _playerHp, Colors.green),
        ],
      ),
    );
  }

  Widget _buildHPBar(String name, double hp, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(hp * 100).toInt()}%',
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: hp.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.8), blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoveSelection() {
    if (!_waitingForMove || !_isPlayerTurn) return const SizedBox.shrink();

    final moves = _moveSets[widget.myAgent.type] ?? _moveSets['Fire']!;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.purple.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.amber.withOpacity(
                0.5 + _pulseController.value * 0.5,
              ),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 20 + _pulseController.value * 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚔️ Select Your Move',
                style: GoogleFonts.poppins(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: moves.length,
                itemBuilder: (context, index) {
                  final move = moves[index];
                  return GestureDetector(
                    onTap: () => _executePlayerMove(move),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (move['color'] as Color).withOpacity(0.8),
                            (move['color'] as Color).withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (move['color'] as Color).withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            move['name'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Power: ${move['power']}',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBattleLog() {
    if (_battleLog.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withOpacity(0.4)),
      ),
      child: ListView.builder(
        controller: _logController,
        itemCount: _battleLog.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              _battleLog[index],
              style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.cyan.withOpacity(0.4)
          ..strokeWidth = 2;

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
