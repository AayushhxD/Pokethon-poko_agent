import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CatchPokemonScreen extends StatefulWidget {
  final Map<String, dynamic> pokemon;
  final Color color;

  const CatchPokemonScreen({
    super.key,
    required this.pokemon,
    required this.color,
  });

  @override
  State<CatchPokemonScreen> createState() => _CatchPokemonScreenState();
}

class _CatchPokemonScreenState extends State<CatchPokemonScreen>
    with TickerProviderStateMixin {
  int _pokeballsLeft = 3;
  bool _isThrowing = false;
  bool _isCaught = false;
  bool _isEscaped = false;
  bool _showResult = false;
  bool _isDragging = false;

  // Drag/Swipe variables - Pokemon GO style
  Offset _pokeballOffset = Offset.zero;
  Offset _dragStartPosition = Offset.zero;
  List<Offset> _dragPath = []; // Track the swipe path for curve ball
  double _pokeballRotation = 0;
  double _throwProgress = 0;
  bool _isFlying = false;
  bool _isCurveBall = false;
  double _curveDirection = 0; // -1 left, 1 right

  // Flying ball position
  Offset _flyingPosition = Offset.zero;
  double _flyingScale = 1.0;
  double _spinAngle = 0;

  late AnimationController _pokemonBounceController;
  late AnimationController _pokeballThrowController;
  late AnimationController _shakeController;
  late AnimationController _captureController;
  late AnimationController _pokemonDodgeController;
  late AnimationController _ballSpinController;
  late ConfettiController _confettiController;

  late Animation<double> _pokemonBounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _captureAnimation;
  late Animation<double> _pokemonDodgeAnimation;

  int _shakeCount = 0;
  double _throwAccuracy = 0; // 0-1, based on swipe accuracy
  bool _showThrowHint = true;

  // Pokemon position for dodge animation
  double _pokemonHorizontalOffset = 0;

  // Target circle for aiming
  double _targetCircleSize = 100;
  bool _showTargetCircle = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Pokemon idle bounce animation
    _pokemonBounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pokemonBounceAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _pokemonBounceController,
        curve: Curves.easeInOut,
      ),
    );

    // Pokeball throw animation (for the flying arc) - smooth duration
    _pokeballThrowController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Ball spin animation for curve balls
    _ballSpinController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Shake animation for pokeball
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Capture shrink animation
    _captureController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _captureAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _captureController, curve: Curves.easeIn),
    );

    // Pokemon dodge animation
    _pokemonDodgeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pokemonDodgeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pokemonDodgeController, curve: Curves.easeOut),
    );

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Animate target circle
    _animateTargetCircle();

    // Hide throw hint after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showThrowHint = false);
    });
  }

  void _animateTargetCircle() async {
    while (mounted && !_isCaught && !_isEscaped) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted && !_isDragging && !_isThrowing) {
        setState(() {
          _targetCircleSize -= 1;
          if (_targetCircleSize < 30) _targetCircleSize = 100;
        });
      }
    }
  }

  @override
  void dispose() {
    // Remove listener if still attached
    if (_throwListener != null) {
      _pokeballThrowController.removeListener(_throwListener!);
      _throwListener = null;
    }
    _pokemonBounceController.dispose();
    _pokeballThrowController.dispose();
    _shakeController.dispose();
    _captureController.dispose();
    _pokemonDodgeController.dispose();
    _ballSpinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getPokemonImageUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  void _onPanStart(DragStartDetails details) {
    if (_isThrowing || _pokeballsLeft <= 0 || _isCaught || _isEscaped) return;

    setState(() {
      _isDragging = true;
      _dragStartPosition = details.localPosition;
      _dragPath = [details.localPosition];
      _showThrowHint = false;
      _showTargetCircle = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging || _isThrowing) return;

    setState(() {
      // Track drag path for curve ball detection
      _dragPath.add(details.localPosition);
      if (_dragPath.length > 20) _dragPath.removeAt(0);

      // Calculate offset from start position
      _pokeballOffset = details.localPosition - _dragStartPosition;

      // Detect curve ball - check if path curves significantly
      _detectCurveBall();

      // Rotate ball based on horizontal movement and curve
      if (_isCurveBall) {
        _pokeballRotation += 0.3 * _curveDirection;
        _spinAngle += 0.5 * _curveDirection;
      } else {
        _pokeballRotation = _pokeballOffset.dx * 0.015;
      }

      // Scale effect - ball gets smaller as you drag up (perspective)
      double dragDistance = _pokeballOffset.dy.abs();
      _throwProgress = (dragDistance / 200).clamp(0.0, 1.0);
    });
  }

  void _detectCurveBall() {
    if (_dragPath.length < 10) return;

    // Calculate total horizontal movement direction changes
    double totalCurve = 0;
    for (int i = 1; i < _dragPath.length; i++) {
      totalCurve += _dragPath[i].dx - _dragPath[i - 1].dx;
    }

    // Check if there's a significant curve pattern
    double avgCurve = totalCurve / _dragPath.length;
    if (avgCurve.abs() > 2) {
      _isCurveBall = true;
      _curveDirection = avgCurve > 0 ? 1 : -1;
    }
  }

  void _onPanEnd(DragEndDetails details) async {
    if (!_isDragging || _isThrowing) return;

    final velocity = details.velocity.pixelsPerSecond;
    final speed = velocity.distance;

    // Very lenient throw detection - accept almost any upward swipe
    // Just need some upward movement OR any reasonable velocity
    bool hasUpwardVelocity = velocity.dy < -100; // Very low threshold
    bool hasUpwardDrag = _pokeballOffset.dy < -20; // Very low threshold
    bool hasSpeed = speed > 100; // Very low threshold

    if (hasUpwardVelocity || hasUpwardDrag || (hasSpeed && velocity.dy < 0)) {
      // Calculate throw accuracy based on:
      // 1. Horizontal deviation from center
      // 2. Speed of throw
      // 3. Curve ball bonus
      double horizontalDeviation = _pokeballOffset.dx.abs();
      double baseAccuracy = (1 - (horizontalDeviation / 120)).clamp(0.2, 1.0);
      double speedBonus = (speed / 2000).clamp(0.0, 0.2);
      double curveBonus = _isCurveBall ? 0.15 : 0;

      _throwAccuracy = (baseAccuracy + speedBonus + curveBonus).clamp(0.3, 1.0);

      await _executeThrow(velocity);
    } else {
      // Not a valid throw, reset position with animation
      _resetBallPosition();
    }
  }

  void _resetBallPosition() {
    setState(() {
      _isDragging = false;
      _pokeballOffset = Offset.zero;
      _pokeballRotation = 0;
      _throwProgress = 0;
      _isCurveBall = false;
      _curveDirection = 0;
      _dragPath = [];
      _showTargetCircle = false;
      _spinAngle = 0;
    });
  }

  // Store listener to remove later
  VoidCallback? _throwListener;

  Future<void> _executeThrow(Offset velocity) async {
    if (_isThrowing || _pokeballsLeft <= 0 || _isCaught || _isEscaped) return;

    final screenSize = MediaQuery.of(context).size;

    // Pokemon is at 0.25 of screen height, add offset to reach center of pokemon
    final pokemonCenterY =
        screenSize.height * 0.25 + 100; // Center of pokemon sprite

    final startX = screenSize.width / 2 + _pokeballOffset.dx;
    final startY = screenSize.height - 100 + _pokeballOffset.dy;

    // Save curve ball state before resetting
    final savedCurveDirection = _curveDirection;
    final savedIsCurveBall = _isCurveBall;
    final curveOffset = savedIsCurveBall ? 100 * savedCurveDirection : 0.0;

    // Calculate throw power based on velocity (key Pokemon GO mechanic)
    final speed = velocity.distance;
    final verticalVelocity = velocity.dy.abs();

    // More forgiving throw power calculation
    // Even slow swipes should reach the Pokemon with decent power
    // Minimum power of 0.7 to ensure most throws reach
    double throwPower = (speed / 1200).clamp(0.7, 1.4);

    // Adjust throw power based on vertical component
    if (verticalVelocity > 300) {
      throwPower *= 1.15; // Bonus for strong upward swipes
    }

    // Ensure even gentle swipes have a good chance
    if (throwPower < 0.85) {
      throwPower = 0.85; // Minimum power to consistently reach Pokemon
    }

    // Reset drag state immediately
    _isDragging = false;
    _pokeballOffset = Offset.zero;
    _isCurveBall = false;
    _curveDirection = 0;
    _dragPath = [];
    _pokeballRotation = 0;
    _throwProgress = 0;

    setState(() {
      _isThrowing = true;
      _isFlying = true;
      _pokeballsLeft--;
      _showTargetCircle = false;
      _flyingPosition = Offset(startX, startY);
      _flyingScale = 1.0;
    });

    // Remove old listener if exists
    if (_throwListener != null) {
      _pokeballThrowController.removeListener(_throwListener!);
      _throwListener = null;
    }

    // Reset and prepare animation
    _pokeballThrowController.reset();

    // Adjust animation duration based on throw power
    // Faster throws = shorter duration, slower throws = longer duration
    final duration = (1000 - (throwPower * 300)).clamp(500, 900).toInt();
    _pokeballThrowController.duration = Duration(milliseconds: duration);

    // Calculate target position based on throw power
    // Weak throws don't reach the Pokemon!
    final targetX = screenSize.width / 2 + (curveOffset * throwPower);

    // Distance traveled depends on throw power
    // Pokemon is at pokemonCenterY, but weak throws fall short
    final maxDistance = startY - pokemonCenterY;
    final actualDistance = maxDistance * throwPower;
    final targetY = startY - actualDistance;

    // Control point for the arc - height based on throw power
    final arcHeight = 150 * throwPower.clamp(0.5, 1.2);
    final controlY = startY - actualDistance * 0.5 - arcHeight;

    // Create the animation listener
    _throwListener = () {
      if (!mounted) return;
      final t = _pokeballThrowController.value;

      // Use linear interpolation for consistent speed, easing for smoothness at end
      final easedT = Curves.easeOut.transform(t);

      // Bezier curve for arc trajectory
      final controlX = startX + curveOffset;

      // Quadratic bezier for smooth arc
      final x =
          pow(1 - easedT, 2) * startX +
          2 * (1 - easedT) * easedT * controlX +
          pow(easedT, 2) * targetX;
      final y =
          pow(1 - easedT, 2) * startY +
          2 * (1 - easedT) * easedT * controlY +
          pow(easedT, 2) * targetY;

      if (mounted) {
        setState(() {
          _flyingPosition = Offset(x.toDouble(), y.toDouble());
          // Scale down as ball gets closer to pokemon
          _flyingScale = 1.0 - (easedT * 0.6);
          if (savedIsCurveBall) {
            _spinAngle += 0.35 * savedCurveDirection;
          }
        });
      }
    };

    _pokeballThrowController.addListener(_throwListener!);

    try {
      await _pokeballThrowController.forward();
    } finally {
      // Always remove listener after animation
      if (_throwListener != null) {
        _pokeballThrowController.removeListener(_throwListener!);
        _throwListener = null;
      }
    }

    if (!mounted) return;

    // Check if ball reached the Pokemon (based on throw power and distance)
    // throwPower directly indicates if we reached the pokemon
    bool reachedPokemon = throwPower >= 0.85;

    // Even if reached, still need some accuracy for the hit
    bool hitPokemon =
        reachedPokemon && (Random().nextDouble() < _throwAccuracy);

    if (!hitPokemon) {
      // Missed! Either didn't reach or Pokemon dodged
      if (!reachedPokemon) {
        // Ball fell short - just land and disappear
        setState(() {
          _isFlying = false;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        _completeThrowReset();
      } else {
        // Reached but missed - Pokemon dodges
        setState(() {
          _isFlying = false;
          _pokemonHorizontalOffset = Random().nextBool() ? 60 : -60;
        });
        await _pokemonDodgeController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        await _pokemonDodgeController.reverse();
        _completeThrowReset();
      }

      if (_pokeballsLeft <= 0) {
        setState(() {
          _isEscaped = true;
          _showResult = true;
        });
      }
      return;
    }

    // Hit! Shrink pokemon (being captured)
    setState(() {
      _isFlying = false;
    });

    await _captureController.forward();

    // Shake animation (3 times) with timeout protection
    _shakeCount = 0;
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      await _shakeController.forward();

      if (!mounted) return;
      await _shakeController.reverse();

      if (mounted) setState(() => _shakeCount = i + 1);

      // Random chance to escape during shake (lower with better accuracy)
      double escapeChance = 0.25 - (_throwAccuracy * 0.15);
      if (Random().nextDouble() < escapeChance && _pokeballsLeft > 0) {
        // Pokemon escapes with burst effect
        if (mounted) {
          await _captureController.reverse();
          _completeThrowReset();
        }
        return;
      }
    }

    if (!mounted) return;

    // Caught! Base chance improved by accuracy and curve ball
    double curveBonus = savedIsCurveBall ? 0.15 : 0;
    double catchChance =
        0.35 +
        (_throwAccuracy * 0.35) +
        curveBonus +
        (0.1 * (3 - _pokeballsLeft));
    bool caught = Random().nextDouble() < catchChance;

    if (caught) {
      // Pokemon caught!
      if (mounted) {
        setState(() {
          _isCaught = true;
          _showResult = true;
          _isThrowing = false;
          _isFlying = false;
        });
      }
      _confettiController.play();
      await _saveCaughtPokemon();

      // Ensure we wait a moment for UI to update
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      // Pokemon escapes
      await _captureController.reverse();
      _completeThrowReset();

      if (_pokeballsLeft <= 0) {
        setState(() {
          _isEscaped = true;
          _showResult = true;
        });
      }
    }
  }

  void _completeThrowReset() {
    _pokeballThrowController.reset();
    _captureController.reset(); // Reset capture animation
    if (mounted) {
      setState(() {
        _isFlying = false;
        _isThrowing = false;
        _flyingPosition = Offset.zero;
        _flyingScale = 1.0;
        _spinAngle = 0;
        _shakeCount = 0;
        _pokemonHorizontalOffset = 0;
        _isDragging = false;
        _pokeballOffset = Offset.zero;
        _pokeballRotation = 0;
        _throwProgress = 0;
        _isCurveBall = false;
        _curveDirection = 0;
        _dragPath = [];
        _showTargetCircle = false;
      });
    }
  }

  Future<void> _saveCaughtPokemon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> caughtPokemon = prefs.getStringList('caught_pokemon') ?? [];

      // Add pokemon to caught list
      String pokemonJson = jsonEncode({
        'name': widget.pokemon['name'],
        'id': widget.pokemon['id'],
        'types': widget.pokemon['types'],
        'caughtAt': DateTime.now().toIso8601String(),
      });

      // Check if already caught
      bool alreadyCaught = caughtPokemon.any((p) {
        Map<String, dynamic> pokemon = jsonDecode(p);
        return pokemon['id'] == widget.pokemon['id'];
      });

      if (!alreadyCaught) {
        caughtPokemon.add(pokemonJson);
        await prefs.setStringList('caught_pokemon', caughtPokemon);
      }
    } catch (e) {
      debugPrint('Error saving caught pokemon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background - Grass field
          _buildBackground(),

          // AR toggle and run button (decorative)
          _buildTopControls(),

          // Target circle (shows when dragging)
          if (_showTargetCircle || _isDragging) _buildTargetCircle(),

          // Pokemon
          _buildPokemon(),

          // Pokemon name and CP
          _buildPokemonInfo(),

          // Flying pokeball
          if (_isFlying) _buildFlyingPokeball(),

          // Pokeball and controls
          _buildBottomControls(),

          // Result overlay
          if (_showResult) _buildResultOverlay(),

          // Confetti
          _buildConfetti(),
        ],
      ),
    );
  }

  Widget _buildTargetCircle() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.25 + 50,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          width: _targetCircleSize,
          height: _targetCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _getTargetColor(), width: 3),
          ),
        ),
      ),
    );
  }

  Color _getTargetColor() {
    if (_targetCircleSize < 40)
      return const Color(0xFF4CAF50); // Excellent - Green
    if (_targetCircleSize < 60)
      return const Color(0xFFFFEB3B); // Great - Yellow
    if (_targetCircleSize < 80) return const Color(0xFFFF9800); // Nice - Orange
    return const Color(0xFFE53935); // Normal - Red
  }

  Widget _buildPokeballWidget(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top red half
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF6B6B),
                  const Color(0xFFEF5350),
                  const Color(0xFFE53935),
                ],
              ),
            ),
          ),
          // Highlight
          Positioned(
            top: size * 0.08,
            left: size * 0.12,
            child: Container(
              width: size * 0.22,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Bottom white half
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size / 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size / 2),
                  bottomRight: Radius.circular(size / 2),
                ),
              ),
            ),
          ),
          // Center line
          Positioned(
            top: (size / 2) - 4,
            left: 0,
            right: 0,
            child: Container(height: 8, color: const Color(0xFF303943)),
          ),
          // Center button
          Center(
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF303943), width: 4),
              ),
              child: Center(
                child: Container(
                  width: size * 0.12,
                  height: size * 0.12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlyingPokeball() {
    return Positioned(
      left: _flyingPosition.dx - 35,
      top: _flyingPosition.dy - 35,
      child: Transform.rotate(
        angle: _spinAngle,
        child: Transform.scale(
          scale: _flyingScale,
          child: _buildPokeballWidget(70),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          'assets/images/catch/catch_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback gradient if image not found
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF87CEEB),
                    const Color(0xFF5BA3D9),
                    const Color(0xFF7BC043),
                    const Color(0xFF5B9A32),
                  ],
                  stops: const [0.0, 0.3, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
        // Slight vignette effect
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Run away button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_run,
                  color: Colors.grey.shade600,
                  size: 28,
                ),
              ),
            ),
            // AR toggle (decorative)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'AR',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4DB6AC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DB6AC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
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

  Widget _buildPokemon() {
    final pokemonId = widget.pokemon['id'] as int;

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.25,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pokemonBounceAnimation,
          _captureAnimation,
          _pokemonDodgeAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _pokemonHorizontalOffset * _pokemonDodgeAnimation.value,
              -_pokemonBounceAnimation.value,
            ),
            child: Transform.scale(
              scale: _captureAnimation.value,
              child: Opacity(
                opacity: _isCaught ? 0 : 1,
                child: CachedNetworkImage(
                  imageUrl: _getPokemonImageUrl(pokemonId),
                  height: 200,
                  fit: BoxFit.contain,
                  placeholder:
                      (context, url) => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.catching_pokemon,
                        size: 150,
                        color: widget.color,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPokemonInfo() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.18,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.catching_pokemon, color: widget.color, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.pokemon['name'],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF303943),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '/',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'CP ${(widget.pokemon['id'] as int) * 15 + Random().nextInt(500)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Swipe hint
        if (_showThrowHint && !_isDragging && !_isThrowing)
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.swipe_up_rounded,
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 8),
                Text(
                  'Swipe up to throw!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Swipe harder to reach further!',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Throw power meter (shows when dragging upward)
        if (_isDragging && _pokeballOffset.dy < -20)
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'POWER',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _throwProgress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE53935),
                              const Color(0xFFFFEB3B),
                              const Color(0xFF4CAF50),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Throw accuracy indicator (shows when dragging)
        if (_isDragging && _throwProgress > 0.2)
          Positioned(
            top: screenSize.height * 0.35,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getAccuracyColor().withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getAccuracyText(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        // Pokeballs remaining indicator
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              bool isUsed = index >= _pokeballsLeft;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isUsed ? 0.3 : 1,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isUsed ? 0.8 : 1.0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUsed ? Colors.grey.shade400 : Colors.red,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 18,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF303943),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Main pokeball - draggable (hidden when flying)
        if (!_isFlying && !_isThrowing)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Transform.translate(
                  offset: _isDragging ? _pokeballOffset : Offset.zero,
                  child: Transform.rotate(
                    angle: _isDragging ? _pokeballRotation : 0,
                    child: Transform.scale(
                      scale: _isDragging ? 1.0 + (_throwProgress * 0.2) : 1.0,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: _isDragging ? 25 : 15,
                              offset: const Offset(0, 8),
                              spreadRadius: _isDragging ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Pokeball top (red)
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFEF5350),
                                    Color(0xFFE53935),
                                  ],
                                ),
                              ),
                            ),
                            // Highlight
                            Positioned(
                              top: 8,
                              left: 12,
                              child: Container(
                                width: 20,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Bottom white half
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 45,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(45),
                                    bottomRight: Radius.circular(45),
                                  ),
                                ),
                              ),
                            ),
                            // Center line
                            Positioned(
                              top: 41,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF303943),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Center button
                            Center(
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF303943),
                                    width: 5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          _isDragging
                                              ? const Color(0xFF4CAF50)
                                              : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Shaking pokeball at pokemon position (after hit)
        if (_isThrowing && !_isFlying)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _shakeCount > 0 ? _shakeAnimation.value : 0,
                    child: Transform.scale(
                      scale: 0.5,
                      child: _buildPokeballWidget(70),
                    ),
                  );
                },
              ),
            ),
          ),

        // Side buttons
        Positioned(
          bottom: 40,
          left: 30,
          child: _buildSideButton(Icons.camera_alt_outlined),
        ),
        Positioned(
          bottom: 40,
          right: 30,
          child: _buildSideButton(Icons.backpack_outlined),
        ),

        // Pokeballs count
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '$_pokeballsLeft',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor() {
    double horizontalDeviation = _pokeballOffset.dx.abs();
    if (horizontalDeviation < 30) return const Color(0xFF4CAF50); // Excellent
    if (horizontalDeviation < 60) return const Color(0xFFFFEB3B); // Great
    if (horizontalDeviation < 100) return const Color(0xFFFF9800); // Nice
    return const Color(0xFFE53935); // Off target
  }

  String _getAccuracyText() {
    double horizontalDeviation = _pokeballOffset.dx.abs();
    if (horizontalDeviation < 30) return 'Excellent!';
    if (horizontalDeviation < 60) return 'Great!';
    if (horizontalDeviation < 100) return 'Nice';
    return 'Off Target';
  }

  Widget _buildSideButton(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.grey.shade600, size: 26),
    );
  }

  Widget _buildResultOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Result icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color:
                      _isCaught
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFE53935).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isCaught ? Icons.check_circle : Icons.cancel,
                  size: 60,
                  color:
                      _isCaught
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 24),
              // Result text
              Text(
                _isCaught ? 'Gotcha!' : 'Oh no!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF303943),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isCaught
                    ? '${widget.pokemon['name']} was caught!'
                    : '${widget.pokemon['name']} escaped!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              if (_isCaught) ...[
                const SizedBox(height: 16),
                // Pokemon image
                CachedNetworkImage(
                  imageUrl: _getPokemonImageUrl(widget.pokemon['id'] as int),
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ],
              const SizedBox(height: 32),
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _isCaught);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isCaught ? 'Awesome!' : 'Try Again Later',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: [
          widget.color,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
        ],
        numberOfParticles: 30,
        gravity: 0.2,
      ),
    );
  }
}
