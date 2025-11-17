import 'package:flutter/material.dart' hide Badge;
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../models/pokeagent.dart';
import '../services/ai_service.dart';
import '../services/badge_service.dart';
import '../widgets/chat_bubble.dart';
import '../data/pokemon_data.dart';
import 'package:poko_agent/screens/training_activities.dart';
import 'package:poko_agent/screens/training_minigames.dart';

class TrainScreen extends StatefulWidget {
  final PokeAgent agent;
  final Function(PokeAgent) onAgentUpdate;

  const TrainScreen({
    super.key,
    required this.agent,
    required this.onAgentUpdate,
  });

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AIService();
  final _badgeService = BadgeService();
  final _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _showDetails = true;
  late PokeAgent _currentAgent;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // Pokemon stats data
  final Map<String, Map<String, dynamic>> _pokemonStats =
      PokemonData.pokemonStats;

  final Map<String, List<Map<String, String>>> _pokemonEvolutions =
      PokemonData.pokemonEvolutions;

  @override
  void initState() {
    super.initState();
    _currentAgent = widget.agent;
    _messages.add({
      'role': 'agent',
      'message': 'Hey trainer! Ready to train? Let\'s get stronger together! ⚡',
    });

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(String type) {
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

  Future<void> _checkAndUnlockBadges() async {
    if (_currentAgent.totalChats == 1) {
      final badge = await _badgeService.unlockBadge('first_chat');
      if (badge != null && mounted) {
        _confettiController.play();
        _showBadgeDialog(badge);
      }
    }

    if (_currentAgent.totalChats == 100) {
      final badge = await _badgeService.unlockBadge('chat_master');
      if (badge != null && mounted) {
        _confettiController.play();
        _showBadgeDialog(badge);
      }
    }
  }

  void _showBadgeDialog(Badge badge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ScaleTransition(
            scale: CurvedAnimation(
              parent: AnimationController(
                duration: const Duration(milliseconds: 300),
                vsync: Navigator.of(context),
              )..forward(),
              curve: Curves.elasticOut,
            ),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: AppTheme.goldColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.goldColor.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      badge.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShaderMask(
                    shaderCallback:
                        (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                    child: Text(
                      'Badge Unlocked!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.goldColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.goldColor.withOpacity(0.2),
                          AppTheme.goldColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppTheme.goldColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.goldColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '+${badge.xpReward} XP',
                          style: const TextStyle(
                            color: AppTheme.goldColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });

    setState(() {
      _messages.add({'role': 'user', 'message': userMessage});
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _aiService.chat(
        agentId: _currentAgent.id,
        agentName: _currentAgent.name,
        agentType: _currentAgent.type,
        message: userMessage,
        personality: _currentAgent.personality,
      );

      if (!mounted) return;

      setState(() {
        _messages.add({'role': 'agent', 'message': response});
        _isLoading = false;

        String newMood = _currentAgent.mood;
        int newMoodLevel = (_currentAgent.moodLevel + 5).clamp(0, 100);

        if (newMoodLevel >= 90) {
          newMood = 'excited';
        } else if (newMoodLevel >= 70) {
          newMood = 'happy';
        }

        _currentAgent = _currentAgent.copyWith(
          xp: _currentAgent.xp + AppConstants.chatXPReward,
          lastInteraction: DateTime.now(),
          totalChats: _currentAgent.totalChats + 1,
          mood: newMood,
          moodLevel: newMoodLevel,
        );

        _checkAndUnlockBadges();
      });

      widget.onAgentUpdate(_currentAgent);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'agent',
          'message': 'Oops! Something went wrong. Try again!',
        });
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getBackgroundColor(_currentAgent.type);

    return Scaffold(
      backgroundColor: typeColor,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/pokeball_pattern.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(typeColor),
                Expanded(
                  child:
                      _showDetails
                          ? _buildDetailsView(typeColor)
                          : _buildChatView(typeColor),
                ),
                if (!_showDetails) _buildInputArea(typeColor),
              ],
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                AppTheme.goldColor,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color typeColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 24,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                // Toggle favorite
              },
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView(Color typeColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Pokemon Image at the top
          Transform.translate(
            offset: const Offset(0, -80),
            child: Hero(
              tag: 'agent-${_currentAgent.id}',
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: CachedNetworkImage(
                  key: UniqueKey(),
                  imageUrl: PokemonData.getPngUrl(_currentAgent.name),
                  placeholder:
                      (context, url) => CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                      ),
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.catching_pokemon,
                        color: typeColor,
                        size: 120,
                      ),
                  fit: BoxFit.cover,
                  memCacheWidth: 200,
                  memCacheHeight: 200,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentAgent.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'N°${_currentAgent.id.toString().padLeft(3, '0')}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Type Badges
                  Row(
                    children: [_buildTypeBadge(_currentAgent.type, typeColor)],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'A powerful Pokémon with incredible abilities. Train with it to unlock its full potential and discover amazing new powers!',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Physical Stats
                  _buildPhysicalStats(typeColor),
                  const SizedBox(height: 24),

                  // Base Stats
                  _buildBaseStats(typeColor),
                  const SizedBox(height: 24),

                  // Abilities
                  _buildAbilities(typeColor),
                  const SizedBox(height: 24),

                  // Gender Ratio
                  _buildGenderRatio(typeColor),
                  const SizedBox(height: 24),

                  // Evolutions
                  _buildEvolutions(typeColor),
                  const SizedBox(height: 24),

                  // Start Training Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showDetails = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Training',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(type), color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            type.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'grass':
        return Icons.grass;
      case 'electric':
        return Icons.bolt;
      case 'psychic':
        return Icons.psychology;
      case 'normal':
        return Icons.circle;
      default:
        return Icons.catching_pokemon;
    }
  }

  Widget _buildPhysicalStats(Color typeColor) {
    final stats = _pokemonStats[_currentAgent.name];
    final height = stats?['height'] ?? 1.1;
    final weight = stats?['weight'] ?? 26.0;
    final category = stats?['category'] ?? _currentAgent.type;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.height,
            label: 'HEIGHT',
            value: '${height}m',
            color: typeColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.monitor_weight_outlined,
            label: 'WEIGHT',
            value: '${weight}kg',
            color: typeColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.category,
            label: 'CATEGORY',
            value: category,
            color: typeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBaseStats(Color typeColor) {
    final stats = _pokemonStats[_currentAgent.name];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Base Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (stats != null) ...[
          _buildStatBar('HP', stats['hp'] ?? 50, 255, typeColor),
          _buildStatBar('Attack', stats['attack'] ?? 50, 255, typeColor),
          _buildStatBar('Defense', stats['defense'] ?? 50, 255, typeColor),
          _buildStatBar('Sp. Atk', stats['sp-attack'] ?? 50, 255, typeColor),
          _buildStatBar('Sp. Def', stats['sp-defense'] ?? 50, 255, typeColor),
          _buildStatBar('Speed', stats['speed'] ?? 50, 255, typeColor),
        ] else ...[
          _buildStatBar('HP', 50, 255, typeColor),
          _buildStatBar('Attack', 60, 255, typeColor),
          _buildStatBar('Defense', 45, 255, typeColor),
          _buildStatBar('Sp. Atk', 70, 255, typeColor),
          _buildStatBar('Sp. Def', 55, 255, typeColor),
          _buildStatBar('Speed', 80, 255, typeColor),
        ],
      ],
    );
  }

  Widget _buildStatBar(String label, int value, int maxValue, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              value.toString().padLeft(3, '0'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (value / maxValue).clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilities(Color typeColor) {
    final stats = _pokemonStats[_currentAgent.name];
    final abilities =
        stats?['abilities'] as List<dynamic>? ?? ['Keen Eye', 'Skill Link'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Abilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              abilities.map((ability) {
                return _buildAbilityChip(ability.toString(), typeColor);
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAbilityChip(String ability, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            ability,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRatio(Color typeColor) {
    final stats = _pokemonStats[_currentAgent.name];
    final gender =
        stats?['gender'] as Map<String, dynamic>? ??
        {'male': 87.5, 'female': 12.5};
    final malePercent = gender['male'] ?? 50.0;
    final femalePercent = gender['female'] ?? 50.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: malePercent.toInt(),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: femalePercent.toInt(),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.pink.shade300,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.male, color: Colors.blue.shade400, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${malePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.female, color: Colors.pink.shade300, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${femalePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvolutions(Color typeColor) {
    final evolutions =
        _pokemonEvolutions[_currentAgent.name] ??
        [
          {'name': 'Base Form', 'level': 'Start'},
          {'name': _currentAgent.name, 'level': 'Lv. ${_currentAgent.level}'},
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolutions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < evolutions.length; i++) ...[
          _buildEvolutionCard(
            evolutions[i]['name']!,
            evolutions[i]['level']!,
            typeColor,
            isCurrent: evolutions[i]['name'] == _currentAgent.name,
          ),
          if (i < evolutions.length - 1) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.arrow_downward, color: typeColor, size: 24),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildEvolutionCard(
    String name,
    String level,
    Color color, {
    bool isCurrent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? color : Colors.grey.shade200,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CachedNetworkImage(
              key: UniqueKey(),
              imageUrl: PokemonData.getPngUrl(name),
              placeholder:
                  (context, url) => CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 2,
                  ),
              errorWidget:
                  (context, url, error) =>
                      Icon(Icons.catching_pokemon, color: color, size: 32),
              fit: BoxFit.cover,
              memCacheWidth: 56,
              memCacheHeight: 56,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatView(Color typeColor) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Toggle Tabs
          _buildToggleTabs(typeColor),

          // Messages
          Expanded(
            child:
                _messages.isEmpty
                    ? _buildEmptyState(typeColor)
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message['role'] == 'user';

                        return SlideInUp(
                          duration: const Duration(milliseconds: 300),
                          delay: Duration(milliseconds: index * 50),
                          from: 30,
                          child: FadeIn(
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ChatBubble(
                                message: message['message']!,
                                isUser: isUser,
                                agentColor: typeColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),

          if (_isLoading) _buildTypingIndicator(typeColor),
        ],
      ),
    );
  }

  Widget _buildToggleTabs(Color typeColor) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showDetails = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    'Chat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Quick Access Training Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.fitness_center,
                  label: 'Activities',
                  color: typeColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TrainingActivitiesScreen(
                              agent: _currentAgent,
                              onAgentUpdate: (agent) {
                                setState(() => _currentAgent = agent);
                                widget.onAgentUpdate(agent);
                              },
                            ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.videogame_asset,
                  label: 'Mini-Games',
                  color: typeColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TrainingMinigamesScreen(
                              agent: _currentAgent,
                              onAgentUpdate: (agent) {
                                setState(() => _currentAgent = agent);
                                widget.onAgentUpdate(agent);
                              },
                            ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color typeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: typeColor.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Start Training!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Send a message to start training\nwith ${_currentAgent.name}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Color typeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          FadeIn(
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: typeColor.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentAgent.name} is thinking...',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: Colors.grey.shade900, fontSize: 15),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Train with ${_currentAgent.name}...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ScaleTransition(
              scale: _fabScaleAnimation,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(26),
                    child: const Center(
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
