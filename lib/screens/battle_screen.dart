import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../models/pokeagent.dart';
import '../services/ai_service.dart';

class BattleScreen extends StatefulWidget {
  final PokeAgent myAgent;
  final List<PokeAgent> allAgents;
  final Function(PokeAgent) onAgentUpdate;

  const BattleScreen({
    super.key,
    required this.myAgent,
    required this.allAgents,
    required this.onAgentUpdate,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with SingleTickerProviderStateMixin {
  PokeAgent? _selectedOpponent;
  bool _isBattling = false;
  bool _battleComplete = false;
  String? _winner;
  List<String> _battleNarrative = [];
  double _myAgentHP = 1.0;
  double _opponentHP = 1.0;
  final _aiService = AIService();
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  List<PokeAgent> get _availableOpponents {
    return widget.allAgents
        .where((agent) => agent.id != widget.myAgent.id)
        .toList();
  }

  Future<void> _startBattle() async {
    if (_selectedOpponent == null) return;

    setState(() {
      _isBattling = true;
      _battleComplete = false;
      _myAgentHP = 1.0;
      _opponentHP = 1.0;
      _battleNarrative = [];
    });

    try {
      final result = await _aiService.battle(
        agent1Id: widget.myAgent.id,
        agent1Name: widget.myAgent.name,
        agent1Type: widget.myAgent.type,
        agent1Stats: widget.myAgent.stats,
        agent2Id: _selectedOpponent!.id,
        agent2Name: _selectedOpponent!.name,
        agent2Type: _selectedOpponent!.type,
        agent2Stats: _selectedOpponent!.stats,
      );

      if (!mounted) return;

      _winner = result['winner'] as String;
      _battleNarrative = List<String>.from(result['narrative'] ?? []);

      // Animate battle
      await _animateBattle();

      final isWinner = _winner == widget.myAgent.name;
      final xpGained =
          isWinner
              ? AppConstants.battleWinXPReward
              : AppConstants.battleLossXPReward;

      final updatedAgent = widget.myAgent.copyWith(
        xp: widget.myAgent.xp + xpGained,
        lastInteraction: DateTime.now(),
        battlesWon:
            isWinner
                ? widget.myAgent.battlesWon + 1
                : widget.myAgent.battlesWon,
        battlesLost:
            !isWinner
                ? widget.myAgent.battlesLost + 1
                : widget.myAgent.battlesLost,
        mood: isWinner ? 'excited' : 'tired',
        moodLevel: isWinner ? 100 : 50,
      );

      widget.onAgentUpdate(updatedAgent);

      setState(() {
        _battleComplete = true;
        _isBattling = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isBattling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Battle failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _animateBattle() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        if (i % 2 == 0) {
          _opponentHP = (1.0 - ((i + 1) / 3)).clamp(0.0, 1.0);
        } else {
          _myAgentHP = (1.0 - ((i + 1) / 3)).clamp(0.0, 1.0);
        }
      });

      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child:
                    _battleComplete
                        ? _buildBattleResult()
                        : _isBattling
                        ? _buildBattleArena()
                        : _buildOpponentSelection(),
              ),

              // Start Battle Button
              if (!_isBattling && !_battleComplete && _selectedOpponent != null)
                _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'Battle Arena',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentSelection() {
    if (_availableOpponents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.white38,
            ),
            const SizedBox(height: 20),
            Text(
              'No opponents available',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Mint more agents to battle!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Select Opponent',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _availableOpponents.length,
            itemBuilder: (context, index) {
              final opponent = _availableOpponents[index];
              final isSelected = _selectedOpponent?.id == opponent.id;
              final typeColor = AppTheme.getTypeColor(opponent.type);

              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOpponent = opponent;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? typeColor : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: typeColor.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: typeColor.withOpacity(0.2),
                            border: Border.all(color: typeColor, width: 2),
                          ),
                          child: Icon(
                            Icons.catching_pokemon,
                            color: typeColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opponent.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${opponent.type} • Lv.${opponent.level}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: typeColor, size: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBattleArena() {
    final myTypeColor = AppTheme.getTypeColor(widget.myAgent.type);
    final opponentTypeColor = AppTheme.getTypeColor(_selectedOpponent!.type);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // My Agent
        FadeInDown(
          child: _buildBattleAgent(
            widget.myAgent,
            myTypeColor,
            _myAgentHP,
            isOpponent: false,
          ),
        ),

        // VS
        ZoomIn(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceColor,
              border: Border.all(color: AppTheme.accentColor, width: 3),
            ),
            child: Text(
              'VS',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: AppTheme.accentColor),
            ),
          ),
        ),

        // Opponent
        FadeInUp(
          child: _buildBattleAgent(
            _selectedOpponent!,
            opponentTypeColor,
            _opponentHP,
            isOpponent: true,
          ),
        ),

        // Narrative
        if (_battleNarrative.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _battleNarrative.last,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildBattleAgent(
    PokeAgent agent,
    Color typeColor,
    double hp, {
    required bool isOpponent,
  }) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = _shakeController.value * 10 * (isOpponent ? 1 : -1);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: typeColor.withOpacity(0.2),
              border: Border.all(color: typeColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(Icons.catching_pokemon, color: typeColor, size: 60),
          ),
          const SizedBox(height: 15),
          Text(agent.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Container(
            width: 200,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 200 * hp,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        hp > 0.5
                            ? [Colors.green, Colors.lightGreen]
                            : hp > 0.25
                            ? [Colors.orange, Colors.yellow]
                            : [Colors.red, Colors.deepOrange],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'HP: ${(hp * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBattleResult() {
    final isWinner = _winner == widget.myAgent.name;
    final resultColor = isWinner ? Colors.greenAccent : Colors.orangeAccent;
    final xpGained =
        isWinner
            ? AppConstants.battleWinXPReward
            : AppConstants.battleLossXPReward;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ZoomIn(
            duration: const Duration(seconds: 1),
            child: Icon(
              isWinner ? Icons.emoji_events : Icons.handshake,
              size: 100,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              isWinner ? 'Victory! 🏆' : 'Good Fight! 🤝',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: resultColor),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'Battle Summary',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 15),
                  ..._battleNarrative.map(
                    (text) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: resultColor),
                    ),
                    child: Text(
                      '+ $xpGained XP',
                      style: TextStyle(
                        color: resultColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startBattle,
            icon: const Icon(Icons.sports_kabaddi),
            label: const Text('Start Battle!'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}
