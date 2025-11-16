import 'package:flutter/material.dart' hide Badge;
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../models/pokeagent.dart';
import '../services/ai_service.dart';
import '../services/badge_service.dart';
import '../widgets/chat_bubble.dart';

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

class _TrainScreenState extends State<TrainScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AIService();
  final _badgeService = BadgeService();
  final _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late PokeAgent _currentAgent;

  @override
  void initState() {
    super.initState();
    _currentAgent = widget.agent;
    _messages.add({
      'role': 'agent',
      'message': 'Hey trainer! Ready to train? Let\'s get stronger together! ⚡',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _checkAndUnlockBadges() async {
    // Check for first chat badge
    if (_currentAgent.totalChats == 1) {
      final badge = await _badgeService.unlockBadge('first_chat');
      if (badge != null && mounted) {
        _confettiController.play();
        _showBadgeDialog(badge);
      }
    }

    // Check for chat master badge
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
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: Row(
              children: [
                Text(badge.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Badge Unlocked!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.goldColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(badge.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.goldColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+${badge.xpReward} XP',
                      style: const TextStyle(color: AppTheme.goldColor),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Awesome!'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

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

        // Update mood based on interaction
        String newMood = _currentAgent.mood;
        int newMoodLevel = (_currentAgent.moodLevel + 5).clamp(0, 100);

        if (newMoodLevel >= 90) {
          newMood = 'excited';
        } else if (newMoodLevel >= 70) {
          newMood = 'happy';
        }

        // Add XP and update stats
        _currentAgent = _currentAgent.copyWith(
          xp: _currentAgent.xp + AppConstants.chatXPReward,
          lastInteraction: DateTime.now(),
          totalChats: _currentAgent.totalChats + 1,
          mood: newMood,
          moodLevel: newMoodLevel,
        );

        // Check for badges
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
    final typeColor = AppTheme.getTypeColor(_currentAgent.type);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(typeColor),

                  // Messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message['role'] == 'user';

                        return FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: ChatBubble(
                            message: message['message']!,
                            isUser: isUser,
                            agentColor: typeColor,
                          ),
                        );
                      },
                    ),
                  ),

                  // Loading Indicator
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      typeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${_currentAgent.name} is thinking...',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Input Area
                  _buildInputArea(),
                ],
              ),
            ),
          ),
          // Confetti overlay
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Hero(
                tag: 'agent-${_currentAgent.id}',
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor.withOpacity(0.2),
                    border: Border.all(color: typeColor, width: 2),
                  ),
                  child: Icon(Icons.catching_pokemon, color: typeColor),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _currentAgent.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentAgent.moodEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      '${_currentAgent.type} • Lv.${_currentAgent.level} • ${_currentAgent.currentMood.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: typeColor, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      '${_currentAgent.xp} XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _currentAgent.xpProgress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(typeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Train with ${_currentAgent.name}...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
                iconSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
