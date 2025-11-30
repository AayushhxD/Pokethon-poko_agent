import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttackButton extends StatefulWidget {
  final String moveName;
  final String emoji;
  final int power;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const AttackButton({
    Key? key,
    required this.moveName,
    required this.emoji,
    required this.power,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AttackButton> createState() => _AttackButtonState();
}

class _AttackButtonState extends State<AttackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getPowerColor(int power) {
    if (power >= 100) {
      return const Color(0xFFFF4444); // Red for high power
    } else if (power >= 70) {
      return const Color(0xFFFFA500); // Orange for medium power
    } else {
      return const Color(0xFF4A90E2); // Blue for low power
    }
  }

  @override
  Widget build(BuildContext context) {
    final powerColor = _getPowerColor(widget.power);

    return GestureDetector(
      onTapDown:
          widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp:
          widget.isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isEnabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      widget.isSelected
                          ? [powerColor, powerColor.withOpacity(0.7)]
                          : [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ],
                ),
                border: Border.all(
                  color:
                      widget.isSelected
                          ? powerColor.withOpacity(_glowAnimation.value)
                          : Colors.white.withOpacity(0.2),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow:
                    widget.isSelected
                        ? [
                          BoxShadow(
                            color: powerColor.withOpacity(
                              _glowAnimation.value * 0.6,
                            ),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                        : [],
              ),
              child: Stack(
                children: [
                  // Glassmorphism effect
                  if (!widget.isSelected)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : powerColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      widget.isSelected
                                          ? Colors.white.withOpacity(0.4)
                                          : powerColor.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${widget.power}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      widget.isSelected
                                          ? Colors.white
                                          : powerColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.moveName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color:
                                    widget.isEnabled
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.power >= 100
                                  ? 'Very Strong'
                                  : widget.power >= 70
                                  ? 'Strong'
                                  : 'Normal',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color:
                                    widget.isEnabled
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Disabled overlay
                  if (!widget.isEnabled)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.5),
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
}
