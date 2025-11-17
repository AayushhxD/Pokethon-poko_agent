import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math';
import '../models/pokeagent.dart';
import '../utils/theme.dart';

class TrainingMinigamesScreen extends StatefulWidget {
  final PokeAgent agent;
  final Function(PokeAgent) onAgentUpdate;

  const TrainingMinigamesScreen({
    super.key,
    required this.agent,
    required this.onAgentUpdate,
  });

  @override
  State<TrainingMinigamesScreen> createState() =>
      _TrainingMinigamesScreenState();
}

class _TrainingMinigamesScreenState extends State<TrainingMinigamesScreen> {
  late PokeAgent _currentAgent;

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

  void _navigateToGame(Widget gameWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameWidget),
    );
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
          'Training Mini-Games',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Play & Earn XP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test your skills in these fun challenges!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Memory Match Game
            _buildGameCard(
              title: 'Memory Match',
              description: 'Match pairs of Pokémon cards',
              icon: Icons.grid_on,
              xpReward: 100,
              difficulty: 'Easy',
              gradient: [Colors.purple.shade400, Colors.pink.shade300],
              index: 0,
              onTap:
                  () => _navigateToGame(
                    MemoryMatchGame(
                      agent: _currentAgent,
                      onComplete: (xp) => _handleGameComplete(xp),
                    ),
                  ),
            ),

            // Reaction Time Game
            _buildGameCard(
              title: 'Quick Tap',
              description: 'Test your reaction speed',
              icon: Icons.touch_app,
              xpReward: 80,
              difficulty: 'Medium',
              gradient: [Colors.orange.shade400, Colors.red.shade300],
              index: 1,
              onTap:
                  () => _navigateToGame(
                    QuickTapGame(
                      agent: _currentAgent,
                      onComplete: (xp) => _handleGameComplete(xp),
                    ),
                  ),
            ),

            // Number Memory
            _buildGameCard(
              title: 'Number Memory',
              description: 'Remember the sequence',
              icon: Icons.psychology,
              xpReward: 120,
              difficulty: 'Hard',
              gradient: [Colors.blue.shade400, Colors.cyan.shade300],
              index: 2,
              onTap:
                  () => _navigateToGame(
                    NumberMemoryGame(
                      agent: _currentAgent,
                      onComplete: (xp) => _handleGameComplete(xp),
                    ),
                  ),
            ),

            // Color Matcher
            _buildGameCard(
              title: 'Color Rush',
              description: 'Match colors before time runs out',
              icon: Icons.palette,
              xpReward: 90,
              difficulty: 'Medium',
              gradient: [Colors.green.shade400, Colors.lime.shade300],
              index: 3,
              onTap:
                  () => _navigateToGame(
                    ColorRushGame(
                      agent: _currentAgent,
                      onComplete: (xp) => _handleGameComplete(xp),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String description,
    required IconData icon,
    required int xpReward,
    required String difficulty,
    required List<Color> gradient,
    required int index,
    required VoidCallback onTap,
  }) {
    Color difficultyColor;
    switch (difficulty) {
      case 'Easy':
        difficultyColor = Colors.green;
        break;
      case 'Medium':
        difficultyColor = Colors.orange;
        break;
      case 'Hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: index * 100),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: Colors.white, size: 32),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          difficulty.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+$xpReward XP',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleGameComplete(int xpEarned) {
    setState(() {
      _currentAgent = _currentAgent.copyWith(
        xp: _currentAgent.xp + xpEarned,
        lastInteraction: DateTime.now(),
      );
    });
    widget.onAgentUpdate(_currentAgent);
  }
}

// Memory Match Mini-Game
class MemoryMatchGame extends StatefulWidget {
  final PokeAgent agent;
  final Function(int) onComplete;

  const MemoryMatchGame({
    super.key,
    required this.agent,
    required this.onComplete,
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  final List<String> _emojis = ['🔥', '💧', '🌿', '⚡', '🔮', '⭐', '🌟', '💫'];
  late List<String> _cards;
  List<int> _flipped = [];
  List<int> _matched = [];
  int _moves = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cards = [..._emojis, ..._emojis];
    _cards.shuffle();
  }

  void _handleCardTap(int index) {
    if (_isProcessing ||
        _flipped.contains(index) ||
        _matched.contains(index) ||
        _flipped.length >= 2) {
      return;
    }

    setState(() {
      _flipped.add(index);
      if (_flipped.length == 2) {
        _moves++;
        _isProcessing = true;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_cards[_flipped[0]] == _cards[_flipped[1]]) {
        setState(() {
          _matched.addAll(_flipped);
          _flipped.clear();
          _isProcessing = false;

          if (_matched.length == _cards.length) {
            _gameComplete();
          }
        });
      } else {
        setState(() {
          _flipped.clear();
          _isProcessing = false;
        });
      }
    });
  }

  void _gameComplete() {
    final xpEarned = max(50, 150 - (_moves * 5));
    widget.onComplete(xpEarned);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              '🎉 Complete!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Moves: $_moves'),
                const SizedBox(height: 8),
                Text(
                  '+$xpEarned XP',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _flipped.clear();
                    _matched.clear();
                    _moves = 0;
                    _initializeGame();
                  });
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memory Match - Moves: $_moves')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final isFlipped =
                _flipped.contains(index) || _matched.contains(index);
            return GestureDetector(
              onTap: () => _handleCardTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isFlipped ? Colors.white : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isFlipped ? _cards[index] : '?',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Quick Tap Game
class QuickTapGame extends StatefulWidget {
  final PokeAgent agent;
  final Function(int) onComplete;

  const QuickTapGame({
    super.key,
    required this.agent,
    required this.onComplete,
  });

  @override
  State<QuickTapGame> createState() => _QuickTapGameState();
}

class _QuickTapGameState extends State<QuickTapGame> {
  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  final Random _random = Random();
  Offset _targetPosition = const Offset(100, 100);

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _timeLeft = 30;
    });
    _moveTarget();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        } else {
          _startTimer();
        }
      });
    });
  }

  void _moveTarget() {
    setState(() {
      _targetPosition = Offset(
        _random.nextDouble() * (MediaQuery.of(context).size.width - 100),
        _random.nextDouble() * (MediaQuery.of(context).size.height - 300),
      );
    });
  }

  void _handleTap() {
    if (!_isPlaying) return;
    setState(() {
      _score++;
    });
    _moveTarget();
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
    });
    final xpEarned = _score * 5;
    widget.onComplete(xpEarned);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Time\'s Up!', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text(
                  '+$xpEarned XP',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Tap - Score: $_score | Time: $_timeLeft'),
      ),
      body: Stack(
        children: [
          if (!_isPlaying)
            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                ),
                child: const Text('Start Game', style: TextStyle(fontSize: 20)),
              ),
            ),
          if (_isPlaying)
            Positioned(
              left: _targetPosition.dx,
              top: _targetPosition.dy,
              child: GestureDetector(
                onTap: _handleTap,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.touch_app, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Number Memory Game
class NumberMemoryGame extends StatefulWidget {
  final PokeAgent agent;
  final Function(int) onComplete;

  const NumberMemoryGame({
    super.key,
    required this.agent,
    required this.onComplete,
  });

  @override
  State<NumberMemoryGame> createState() => _NumberMemoryGameState();
}

class _NumberMemoryGameState extends State<NumberMemoryGame> {
  int _level = 1;
  List<int> _sequence = [];
  List<int> _userSequence = [];
  bool _showingSequence = false;
  bool _userTurn = false;
  String _displayNumber = '';

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    setState(() {
      _sequence = List.generate(_level + 2, (_) => Random().nextInt(10));
      _userSequence = [];
      _showingSequence = true;
      _userTurn = false;
    });
    _showSequence();
  }

  void _showSequence() async {
    for (int num in _sequence) {
      setState(() => _displayNumber = num.toString());
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _displayNumber = '');
      await Future.delayed(const Duration(milliseconds: 200));
    }
    setState(() {
      _showingSequence = false;
      _userTurn = true;
    });
  }

  void _handleNumberTap(int number) {
    if (!_userTurn) return;

    setState(() {
      _userSequence.add(number);
    });

    if (_userSequence.length == _sequence.length) {
      _checkSequence();
    }
  }

  void _checkSequence() {
    bool correct = true;
    for (int i = 0; i < _sequence.length; i++) {
      if (_userSequence[i] != _sequence[i]) {
        correct = false;
        break;
      }
    }

    if (correct) {
      setState(() => _level++);
      Future.delayed(const Duration(seconds: 1), () => _startLevel());
    } else {
      _endGame();
    }
  }

  void _endGame() {
    final xpEarned = (_level - 1) * 20;
    widget.onComplete(xpEarned);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Game Over!', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level Reached: ${_level - 1}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '+$xpEarned XP',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _level = 1);
                  _startLevel();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Number Memory - Level $_level')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showingSequence)
            Text(
              _displayNumber,
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (!_showingSequence && !_userTurn)
            const CircularProgressIndicator(),
          if (_userTurn) ...[
            const Text(
              'Your Turn!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              padding: const EdgeInsets.all(20),
              itemCount: 10,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () => _handleNumberTap(index),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Text(
                    index.toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// Color Rush Game
class ColorRushGame extends StatefulWidget {
  final PokeAgent agent;
  final Function(int) onComplete;

  const ColorRushGame({
    super.key,
    required this.agent,
    required this.onComplete,
  });

  @override
  State<ColorRushGame> createState() => _ColorRushGameState();
}

class _ColorRushGameState extends State<ColorRushGame> {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final List<String> _colorNames = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Purple',
    'Orange',
  ];

  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  Color _targetColor = Colors.red;
  String _displayText = 'Red';
  Color _textColor = Colors.red;

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _timeLeft = 30;
    });
    _generateChallenge();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        } else {
          _startTimer();
        }
      });
    });
  }

  void _generateChallenge() {
    final random = Random();
    setState(() {
      _targetColor = _colors[random.nextInt(_colors.length)];
      _displayText = _colorNames[random.nextInt(_colorNames.length)];
      _textColor = _colors[random.nextInt(_colors.length)];
    });
  }

  void _handleAnswer(bool colorMatches) {
    final correct = (_targetColor == _textColor) == colorMatches;

    if (correct) {
      setState(() => _score++);
    }
    _generateChallenge();
  }

  void _endGame() {
    setState(() => _isPlaying = false);
    final xpEarned = _score * 3;
    widget.onComplete(xpEarned);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Time\'s Up!', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text(
                  '+$xpEarned XP',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color Rush - Score: $_score | Time: $_timeLeft'),
      ),
      body: Center(
        child:
            !_isPlaying
                ? ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Start Game',
                    style: TextStyle(fontSize: 20),
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Does the text color match?',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _displayText,
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _handleAnswer(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                          ),
                          child: const Text(
                            'YES',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _handleAnswer(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                          ),
                          child: const Text(
                            'NO',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
