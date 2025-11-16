import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/theme.dart';
import '../models/pokeagent.dart';
import '../services/ai_service.dart';

class EvolutionScreen extends StatefulWidget {
  final PokeAgent agent;
  final Function(PokeAgent) onAgentUpdate;

  const EvolutionScreen({
    super.key,
    required this.agent,
    required this.onAgentUpdate,
  });

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen>
    with SingleTickerProviderStateMixin {
  bool _isEvolving = false;
  bool _evolutionComplete = false;
  late PokeAgent _evolvedAgent;
  final _aiService = AIService();
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _evolvedAgent = widget.agent;
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _evolve() async {
    setState(() {
      _isEvolving = true;
    });

    try {
      final newStage = widget.agent.evolutionStage + 1;

      final evolutionData = await _aiService.evolve(
        agentId: widget.agent.id,
        agentName: widget.agent.name,
        agentType: widget.agent.type,
        newStage: newStage,
      );

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Update stats
      final newStats = Map<String, int>.from(widget.agent.stats);
      final statBoost =
          evolutionData['statBoost'] as Map<String, dynamic>? ?? {};

      statBoost.forEach((key, value) {
        newStats[key] = (newStats[key] ?? 0) + (value as int);
      });

      _evolvedAgent = widget.agent.copyWith(
        name: evolutionData['newName'] as String? ?? widget.agent.name,
        evolutionStage: newStage,
        imageUrl:
            evolutionData['newImageUrl'] as String? ?? widget.agent.imageUrl,
        stats: newStats,
      );

      widget.onAgentUpdate(_evolvedAgent);

      setState(() {
        _isEvolving = false;
        _evolutionComplete = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isEvolving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evolution failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.getTypeColor(widget.agent.type);

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
                    _evolutionComplete
                        ? _buildEvolutionComplete(typeColor)
                        : _isEvolving
                        ? _buildEvolutionAnimation(typeColor)
                        : _buildEvolutionInfo(typeColor),
              ),

              // Evolve Button
              if (!_isEvolving && !_evolutionComplete)
                _buildEvolveButton(typeColor),
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
          Text('Evolution', style: Theme.of(context).textTheme.displayMedium),
        ],
      ),
    );
  }

  Widget _buildEvolutionInfo(Color typeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Agent Display
          FadeInDown(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor.withOpacity(0.2),
                    border: Border.all(color: typeColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(
                          _glowController.value * 0.8,
                        ),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.catching_pokemon,
                    color: typeColor,
                    size: 100,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // Agent Info
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              widget.agent.name,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),

          const SizedBox(height: 10),

          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.agent.type} • Stage ${widget.agent.evolutionStage}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Evolution Arrow
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Icon(
              Icons.arrow_downward,
              size: 50,
              color: Colors.yellow.shade600,
            ),
          ),

          const SizedBox(height: 20),

          // Next Stage Info
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glowingCardDecoration(typeColor),
              child: Column(
                children: [
                  Text(
                    'Next Evolution',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Stage ${widget.agent.evolutionStage + 1}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.yellow.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Stat Boosts',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildStatBoost('HP', 20),
                      _buildStatBoost('ATK', 15),
                      _buildStatBoost('DEF', 15),
                      _buildStatBoost('SPD', 10),
                      _buildStatBoost('SP', 20),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Current Stats
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Stats',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 15),
                  ...widget.agent.stats.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            entry.value.toString(),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBoost(String stat, int boost) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Text(
        '$stat +$boost',
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEvolutionAnimation(Color typeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Pulse(
            infinite: true,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withOpacity(0.2),
                border: Border.all(color: Colors.yellow, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.8),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.yellow.shade600,
                size: 100,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Evolving...',
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: Colors.yellow.shade600),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionComplete(Color typeColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZoomIn(
              duration: const Duration(seconds: 1),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: typeColor.withOpacity(0.2),
                  border: Border.all(color: typeColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.8),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.catching_pokemon,
                  color: typeColor,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Text(
                'Evolution Complete! ✨',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.yellow.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: Text(
                _evolvedAgent.name,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Stage ${_evolvedAgent.evolutionStage}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 1000),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolveButton(Color typeColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.agent.canEvolve ? _evolve : null,
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              widget.agent.canEvolve
                  ? 'Evolve Now!'
                  : 'Not Ready (Need ${widget.agent.evolutionStage == 1
                      ? 100
                      : widget.agent.evolutionStage == 2
                      ? 300
                      : 600} XP)',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor:
                  widget.agent.canEvolve
                      ? Colors.yellow.shade600
                      : AppTheme.surfaceColor,
            ),
          ),
        ),
      ),
    );
  }
}
