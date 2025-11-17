import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokeagent.dart';
import '../utils/theme.dart';
import 'battle_result_screen.dart';

class BattleArenaScreen extends StatefulWidget {
  final PokeAgent playerAgent;
  final PokeAgent opponentAgent;

  const BattleArenaScreen({
    super.key,
    required this.playerAgent,
    required this.opponentAgent,
  });

  @override
  State<BattleArenaScreen> createState() => _BattleArenaScreenState();
}

class _BattleArenaScreenState extends State<BattleArenaScreen>
    with TickerProviderStateMixin {
  double _playerHP = 1.0;
  double _opponentHP = 1.0;
  double _energyMeter = 0.0;
  bool _isPlayerTurn = true;
  bool _battleEnded = false;
  String _winner = '';
  List<String> _battleLog = [];
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _battleLog.add(
      'Battle started! ${widget.playerAgent.name} vs ${widget.opponentAgent.name}',
    );
    _battleLog.add('${widget.playerAgent.name} goes first!');
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopSection(),
              Expanded(child: _buildArenaSection()),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Opponent info
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.getTypeColor(
                          widget.opponentAgent.type,
                        ).withOpacity(0.3),
                        border: Border.all(
                          color: AppTheme.getTypeColor(
                            widget.opponentAgent.type,
                          ),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.catching_pokemon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.opponentAgent.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Lv.${widget.opponentAgent.level}',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildHPBar(_opponentHP, false),
              ],
            ),
          ),

          // Turn indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  _isPlayerTurn
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isPlayerTurn ? Colors.blue : Colors.red,
                width: 1,
              ),
            ),
            child: Text(
              _isPlayerTurn ? 'Your Turn' : 'Opponent Turn',
              style: GoogleFonts.poppins(
                color: _isPlayerTurn ? Colors.blue : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Player info
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.playerAgent.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Lv.${widget.playerAgent.level}',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.getTypeColor(
                          widget.playerAgent.type,
                        ).withOpacity(0.3),
                        border: Border.all(
                          color: AppTheme.getTypeColor(widget.playerAgent.type),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.catching_pokemon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildHPBar(_playerHP, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHPBar(double hp, bool isPlayer) {
    return Column(
      crossAxisAlignment:
          isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          'HP: ${(hp * 100).toInt()}%',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: hp,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                hp > 0.5
                    ? Colors.green
                    : hp > 0.25
                    ? Colors.yellow
                    : Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArenaSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/battle_arena.png',
          ), // Add arena background
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          children: [
            // Creatures
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Opponent creature
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final shake = _shakeController.value * 20;
                      return Transform.translate(
                        offset: Offset(shake, 0),
                        child: _buildCreatureDisplay(
                          widget.opponentAgent,
                          false,
                        ),
                      );
                    },
                  ),

                  // VS indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'VS',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Player creature
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final shake = _shakeController.value * -20;
                      return Transform.translate(
                        offset: Offset(shake, 0),
                        child: _buildCreatureDisplay(widget.playerAgent, true),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Battle log
            Container(
              height: 80,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ListView.builder(
                itemCount: _battleLog.length,
                itemBuilder: (context, index) {
                  return Text(
                    _battleLog[index],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatureDisplay(PokeAgent agent, bool isPlayer) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.getTypeColor(agent.type).withOpacity(0.2),
            border: Border.all(
              color: AppTheme.getTypeColor(agent.type),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getTypeColor(agent.type).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.catching_pokemon,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          agent.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Energy meter
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _energyMeter,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ultimate Energy: ${(_energyMeter * 100).toInt()}%',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 20),

          // Move buttons
          Row(
            children: [
              Expanded(
                child: _buildMoveButton('Attack', Colors.red, _performAttack),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMoveButton(
                  'Special',
                  Colors.blue,
                  _performSpecial,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMoveButton(
                  'Defense',
                  Colors.green,
                  _performDefense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMoveButton(
                  'Ultimate',
                  Colors.purple,
                  _energyMeter >= 1.0 ? _performUltimate : null,
                  disabled: _energyMeter < 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoveButton(
    String label,
    Color color,
    VoidCallback? onPressed, {
    bool disabled = false,
  }) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor:
            disabled ? Colors.grey.withOpacity(0.3) : color.withOpacity(0.8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: color,
        elevation: disabled ? 0 : 8,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  void _performAttack() {
    _executeMove('Attack', 0.15, 'deals damage with a powerful strike!');
  }

  void _performSpecial() {
    _executeMove('Special Attack', 0.25, 'unleashes a special ability!');
  }

  void _performDefense() {
    setState(() {
      _battleLog.add('${widget.playerAgent.name} takes a defensive stance!');
      _energyMeter = (_energyMeter + 0.2).clamp(0.0, 1.0);
      _isPlayerTurn = false;
    });

    // Simulate opponent turn
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _opponentTurn();
    });
  }

  void _performUltimate() {
    _executeMove('Ultimate Attack', 0.4, 'unleashes the ultimate power!');
    setState(() {
      _energyMeter = 0.0;
    });
  }

  void _executeMove(String moveName, double damage, String description) {
    setState(() {
      _battleLog.add(
        '${widget.playerAgent.name} uses $moveName and $description',
      );
      _opponentHP = (_opponentHP - damage).clamp(0.0, 1.0);
      _energyMeter = (_energyMeter + 0.1).clamp(0.0, 1.0);
      _shakeController.forward(from: 0);
    });

    if (_opponentHP <= 0) {
      _endBattle(widget.playerAgent.name);
      return;
    }

    setState(() {
      _isPlayerTurn = false;
    });

    // Simulate opponent turn
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _opponentTurn();
    });
  }

  void _opponentTurn() {
    if (_battleEnded) return;

    final moves = ['Attack', 'Special Attack', 'Defense'];
    final move = moves[DateTime.now().millisecondsSinceEpoch % moves.length];
    final damage =
        move == 'Attack'
            ? 0.12
            : move == 'Special Attack'
            ? 0.2
            : 0.0;

    setState(() {
      if (move == 'Defense') {
        _battleLog.add(
          '${widget.opponentAgent.name} takes a defensive stance!',
        );
      } else {
        _battleLog.add('${widget.opponentAgent.name} uses $move!');
        _playerHP = (_playerHP - damage).clamp(0.0, 1.0);
        _shakeController.forward(from: 0);
      }
      _isPlayerTurn = true;
    });

    if (_playerHP <= 0) {
      _endBattle(widget.opponentAgent.name);
    }
  }

  void _endBattle(String winner) {
    setState(() {
      _battleEnded = true;
      _winner = winner;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => BattleResultScreen(
                winner: winner,
                playerAgent: widget.playerAgent,
                opponentAgent: widget.opponentAgent,
                isPlayerWinner: winner == widget.playerAgent.name,
              ),
        ),
      );
    });
  }
}
