import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/pokeagent.dart';

class TrainingActivitiesScreen extends StatefulWidget {
  final PokeAgent agent;
  final Function(PokeAgent) onAgentUpdate;

  const TrainingActivitiesScreen({
    super.key,
    required this.agent,
    required this.onAgentUpdate,
  });

  @override
  State<TrainingActivitiesScreen> createState() =>
      _TrainingActivitiesScreenState();
}

class _TrainingActivitiesScreenState extends State<TrainingActivitiesScreen>
    with TickerProviderStateMixin {
  late PokeAgent _currentAgent;
  bool _isTraining = false;

  @override
  void initState() {
    super.initState();
    _currentAgent = widget.agent;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF9D55);
      case 'water':
        return const Color(0xFF5DADE2);
      case 'grass':
        return const Color(0xFF85C47C);
      case 'electric':
        return const Color(0xFFF7D358);
      case 'psychic':
        return const Color(0xFFFA92B2);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Future<void> _performActivity(String activity, int xpReward) async {
    if (_isTraining) return;

    setState(() => _isTraining = true);

    // Simulate training
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _currentAgent = _currentAgent.copyWith(
        xp: _currentAgent.xp + xpReward,
        lastInteraction: DateTime.now(),
      );
      _isTraining = false;
    });

    widget.onAgentUpdate(_currentAgent);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star, color: Colors.white),
              const SizedBox(width: 12),
              Text('$activity complete! +$xpReward XP'),
            ],
          ),
          backgroundColor: _getTypeColor(_currentAgent.type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(_currentAgent.type);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: typeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Training Activities',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agent Info Card
                _buildAgentInfoCard(typeColor),
                const SizedBox(height: 24),

                // Training Activities Title
                const Text(
                  'Choose Your Training',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete activities to earn XP and level up!',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Activity Cards
                _buildActivityCard(
                  icon: Icons.fitness_center,
                  title: 'Power Training',
                  description: 'Boost attack and strength',
                  xpReward: 50,
                  duration: '2 min',
                  color: Colors.red.shade400,
                  gradient: [Colors.red.shade400, Colors.orange.shade300],
                  index: 0,
                ),
                _buildActivityCard(
                  icon: Icons.shield,
                  title: 'Defense Drill',
                  description: 'Improve defense and endurance',
                  xpReward: 45,
                  duration: '2 min',
                  color: Colors.blue.shade400,
                  gradient: [Colors.blue.shade400, Colors.cyan.shade300],
                  index: 1,
                ),
                _buildActivityCard(
                  icon: Icons.bolt,
                  title: 'Speed Training',
                  description: 'Enhance speed and agility',
                  xpReward: 55,
                  duration: '2 min',
                  color: Colors.yellow.shade600,
                  gradient: [Colors.yellow.shade600, Colors.amber.shade400],
                  index: 2,
                ),
                _buildActivityCard(
                  icon: Icons.psychology,
                  title: 'Mental Focus',
                  description: 'Sharpen special abilities',
                  xpReward: 60,
                  duration: '2 min',
                  color: Colors.purple.shade400,
                  gradient: [Colors.purple.shade400, Colors.pink.shade300],
                  index: 3,
                ),
                _buildActivityCard(
                  icon: Icons.restaurant,
                  title: 'Energy Boost',
                  description: 'Restore HP and stamina',
                  xpReward: 40,
                  duration: '1 min',
                  color: Colors.green.shade400,
                  gradient: [Colors.green.shade400, Colors.lightGreen.shade300],
                  index: 4,
                ),
                _buildActivityCard(
                  icon: Icons.explore,
                  title: 'Adventure Quest',
                  description: 'Explore and gain experience',
                  xpReward: 75,
                  duration: '3 min',
                  color: Colors.indigo.shade400,
                  gradient: [Colors.indigo.shade400, Colors.blue.shade300],
                  index: 5,
                ),
              ],
            ),
          ),
          if (_isTraining)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: FadeIn(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Training in Progress...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_currentAgent.name} is working hard!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgentInfoCard(Color typeColor) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [typeColor, typeColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getTypeEmoji(_currentAgent.type),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentAgent.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${_currentAgent.level}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentAgent.xp} XP',
                          style: const TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String description,
    required int xpReward,
    required String duration,
    required Color color,
    required List<Color> gradient,
    required int index,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: index * 100),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isTraining ? null : () => _performActivity(title, xpReward),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: color, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+$xpReward XP',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: Colors.grey.shade600,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    duration,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: color, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return '🔥';
      case 'water':
        return '💧';
      case 'grass':
        return '🌿';
      case 'electric':
        return '⚡';
      case 'psychic':
        return '🔮';
      default:
        return '⭐';
    }
  }
}
