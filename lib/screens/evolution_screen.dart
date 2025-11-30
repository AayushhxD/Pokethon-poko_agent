import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/pokeagent.dart';
import '../services/ai_service.dart';
import '../services/wallet_service.dart';

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
  bool _isProcessingPayment = false;
  late PokeAgent _evolvedAgent;
  final _aiService = AIService();
  late AnimationController _glowController;

  // Wallet & Rewards
  double _walletBalance = 2.5; // ETH balance
  int _rewardPoints = 500; // Reward points earned from battles/training
  int _selectedPaymentMethod = 0; // 0 = ETH, 1 = Reward Points

  // Evolution costs
  double get _evolutionCostETH {
    switch (widget.agent.evolutionStage) {
      case 1:
        return 0.05;
      case 2:
        return 0.1;
      default:
        return 0.2;
    }
  }

  int get _evolutionCostPoints {
    switch (widget.agent.evolutionStage) {
      case 1:
        return 200;
      case 2:
        return 500;
      default:
        return 1000;
    }
  }

  @override
  void initState() {
    super.initState();
    _evolvedAgent = widget.agent;
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletBalance = prefs.getDouble('wallet_balance') ?? 2.5;
      _rewardPoints = prefs.getInt('reward_points') ?? 500;
    });
  }

  Future<void> _saveWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', _walletBalance);
    await prefs.setInt('reward_points', _rewardPoints);
  }

  // Type colors
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFEE8130);
      case 'water':
        return const Color(0xFF6390F0);
      case 'grass':
        return const Color(0xFF7AC74C);
      case 'electric':
        return const Color(0xFFF7D02C);
      case 'psychic':
        return const Color(0xFFF95587);
      case 'ice':
        return const Color(0xFF96D9D6);
      case 'dragon':
        return const Color(0xFF6F35FC);
      case 'dark':
        return const Color(0xFF705746);
      case 'fairy':
        return const Color(0xFFD685AD);
      case 'fighting':
        return const Color(0xFFC22E28);
      case 'flying':
        return const Color(0xFFA98FF3);
      case 'poison':
        return const Color(0xFFA33EA1);
      case 'ground':
        return const Color(0xFFE2BF65);
      case 'rock':
        return const Color(0xFFB6A136);
      case 'bug':
        return const Color(0xFFA6B91A);
      case 'ghost':
        return const Color(0xFF735797);
      case 'steel':
        return const Color(0xFFB7B7CE);
      case 'normal':
      default:
        return const Color(0xFFA8A77A);
    }
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
      case 'ice':
        return Icons.ac_unit;
      case 'dragon':
        return Icons.whatshot;
      case 'dark':
        return Icons.dark_mode;
      case 'fairy':
        return Icons.auto_awesome;
      case 'fighting':
        return Icons.sports_mma;
      case 'flying':
        return Icons.air;
      case 'poison':
        return Icons.science;
      case 'ground':
        return Icons.landscape;
      case 'rock':
        return Icons.terrain;
      case 'bug':
        return Icons.bug_report;
      case 'ghost':
        return Icons.blur_on;
      case 'steel':
        return Icons.shield;
      case 'normal':
      default:
        return Icons.catching_pokemon;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _showEvolutionPaymentDialog(Color typeColor) {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(20),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: typeColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [typeColor.withOpacity(0.9), typeColor],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'NFT EVOLUTION',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Pokemon Image
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 3,
                                  ),
                                ),
                                child:
                                    widget.agent.displayImageUrl.isNotEmpty
                                        ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                widget.agent.displayImageUrl,
                                            fit: BoxFit.contain,
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.catching_pokemon,
                                                  size: 50,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                          ),
                                        )
                                        : Icon(
                                          Icons.catching_pokemon,
                                          size: 50,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.agent.name,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Stage ${widget.agent.evolutionStage}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.amber.shade300,
                                      size: 18,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Stage ${widget.agent.evolutionStage + 1}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Payment Options
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Payment Method',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ETH Payment Option
                              GestureDetector(
                                onTap: () {
                                  setDialogState(
                                    () => _selectedPaymentMethod = 0,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedPaymentMethod == 0
                                            ? const Color(
                                              0xFF627EEA,
                                            ).withOpacity(0.1)
                                            : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          _selectedPaymentMethod == 0
                                              ? const Color(0xFF627EEA)
                                              : Colors.grey.shade200,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF627EEA,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Ξ',
                                          style: TextStyle(
                                            color: Color(0xFF627EEA),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Pay with ETH',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Balance: ${_walletBalance.toStringAsFixed(3)} ETH',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color:
                                                    _walletBalance >=
                                                            _evolutionCostETH
                                                        ? Colors.green.shade600
                                                        : Colors.red.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${_evolutionCostETH.toStringAsFixed(3)} ETH',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF627EEA),
                                            ),
                                          ),
                                          if (_walletBalance <
                                              _evolutionCostETH)
                                            Text(
                                              'Insufficient',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Radio<int>(
                                        value: 0,
                                        groupValue: _selectedPaymentMethod,
                                        onChanged: (val) {
                                          setDialogState(
                                            () => _selectedPaymentMethod = val!,
                                          );
                                        },
                                        activeColor: const Color(0xFF627EEA),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Reward Points Payment Option
                              GestureDetector(
                                onTap: () {
                                  setDialogState(
                                    () => _selectedPaymentMethod = 1,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedPaymentMethod == 1
                                            ? Colors.amber.withOpacity(0.1)
                                            : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          _selectedPaymentMethod == 1
                                              ? Colors.amber.shade600
                                              : Colors.grey.shade200,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.stars_rounded,
                                          color: Colors.amber.shade600,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Reward Points',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Balance: $_rewardPoints pts',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color:
                                                    _rewardPoints >=
                                                            _evolutionCostPoints
                                                        ? Colors.green.shade600
                                                        : Colors.red.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$_evolutionCostPoints pts',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.amber.shade700,
                                            ),
                                          ),
                                          if (_rewardPoints <
                                              _evolutionCostPoints)
                                            Text(
                                              'Insufficient',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Radio<int>(
                                        value: 1,
                                        groupValue: _selectedPaymentMethod,
                                        onChanged: (val) {
                                          setDialogState(
                                            () => _selectedPaymentMethod = val!,
                                          );
                                        },
                                        activeColor: Colors.amber.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Info note
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Evolution is recorded on blockchain as NFT upgrade',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Evolve Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      _canAffordEvolution()
                                          ? () async {
                                            setDialogState(
                                              () => _isProcessingPayment = true,
                                            );

                                            // Simulate blockchain transaction
                                            await Future.delayed(
                                              const Duration(seconds: 2),
                                            );

                                            // Deduct payment
                                            setState(() {
                                              if (_selectedPaymentMethod == 0) {
                                                _walletBalance -=
                                                    _evolutionCostETH;
                                              } else {
                                                _rewardPoints -=
                                                    _evolutionCostPoints;
                                              }
                                            });

                                            await _saveWalletData();

                                            setDialogState(
                                              () =>
                                                  _isProcessingPayment = false,
                                            );
                                            Navigator.pop(context);

                                            // Start evolution
                                            _evolve();
                                          }
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _canAffordEvolution()
                                            ? typeColor
                                            : Colors.grey.shade300,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: _canAffordEvolution() ? 4 : 0,
                                    shadowColor: typeColor.withOpacity(0.4),
                                  ),
                                  child:
                                      _isProcessingPayment
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Processing...',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.auto_awesome,
                                                size: 20,
                                                color:
                                                    _canAffordEvolution()
                                                        ? Colors.white
                                                        : Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                _canAffordEvolution()
                                                    ? 'Evolve Now'
                                                    : 'Insufficient Balance',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      _canAffordEvolution()
                                                          ? Colors.white
                                                          : Colors
                                                              .grey
                                                              .shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Secure note
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.grey.shade400,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Secure blockchain transaction',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  bool _canAffordEvolution() {
    if (_selectedPaymentMethod == 0) {
      return _walletBalance >= _evolutionCostETH;
    } else {
      return _rewardPoints >= _evolutionCostPoints;
    }
  }

  Future<void> _evolve() async {
    final walletService = Provider.of<WalletService>(context, listen: false);

    // Check if user has enough balance
    if (!walletService.hasEnoughBalance(WalletService.evolveCost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Insufficient balance! Need ${WalletService.evolveCost.toInt()} POKO to evolve',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Deduct evolution cost
    await walletService.deductTokens(WalletService.evolveCost);

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

      // Refund on failure
      await walletService.addTokens(WalletService.evolveCost);

      setState(() {
        _isEvolving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Evolution failed: $e',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.agent.type);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.grey.shade700,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolution',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Transform your Pokemon',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.amber.shade600,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionInfo(Color typeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Agent Display Card
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    typeColor.withOpacity(0.8),
                    typeColor,
                    typeColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Pokemon Image with glow effect
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(
                                _glowController.value * 0.5,
                              ),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child:
                            widget.agent.displayImageUrl.isNotEmpty
                                ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: widget.agent.displayImageUrl,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.contain,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Icon(
                                          Icons.catching_pokemon,
                                          size: 80,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                  ),
                                )
                                : Icon(
                                  Icons.catching_pokemon,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 80,
                                ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Pokemon Name
                  Text(
                    widget.agent.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Type and Stage badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(widget.agent.type),
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.agent.type,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Stage ${widget.agent.evolutionStage}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Evolution Arrow
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade200, width: 2),
              ),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 32,
                color: Colors.amber.shade600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Next Evolution Card
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.amber.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Evolution',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Stage ${widget.agent.evolutionStage + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.amber.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Stat Boosts Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Stat Boosts',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildStatBoostChip('HP', 20),
                            _buildStatBoostChip('ATK', 15),
                            _buildStatBoostChip('DEF', 15),
                            _buildStatBoostChip('SPD', 10),
                            _buildStatBoostChip('SP', 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Current Stats Card
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.bar_chart_rounded,
                          color: typeColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Current Stats',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.agent.stats.entries.map((entry) {
                    return _buildStatRow(entry.key, entry.value, typeColor);
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatBoostChip(String stat, int boost) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '+$boost',
            style: GoogleFonts.poppins(
              color: Colors.green.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String statName, int value, Color typeColor) {
    final maxStat = 200;
    final progress = value / maxStat;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statName.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(typeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionAnimation(Color typeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated evolution container
          Pulse(
            infinite: true,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    Colors.amber.shade100,
                    Colors.amber.shade300,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.amber.shade600,
                  size: 80,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            'Evolving...',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.amber.shade600,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Please wait while your Pokemon transforms',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.amber.shade600,
                ),
              ),
            ),
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
            // Success Badge
            ZoomIn(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade200, width: 3),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.green.shade600,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 24),

            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Evolution Complete! ✨',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Evolved Pokemon Card
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [typeColor.withOpacity(0.8), typeColor],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                      child:
                          _evolvedAgent.displayImageUrl.isNotEmpty
                              ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _evolvedAgent.displayImageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorWidget:
                                      (context, url, error) => Icon(
                                        Icons.catching_pokemon,
                                        size: 70,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                ),
                              )
                              : Icon(
                                Icons.catching_pokemon,
                                color: Colors.white.withOpacity(0.9),
                                size: 70,
                              ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _evolvedAgent.name,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber.shade300,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Stage ${_evolvedAgent.evolutionStage}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Return Button
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: typeColor.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Return to Home',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolveButton(Color typeColor) {
    final canEvolve = widget.agent.canEvolve;
    final requiredXP =
        widget.agent.evolutionStage == 1
            ? 100
            : widget.agent.evolutionStage == 2
            ? 300
            : 600;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Wallet Balance Card
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667eea).withOpacity(0.1),
                    const Color(0xFF764ba2).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF667eea).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // ETH Balance
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF627EEA).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Ξ',
                            style: TextStyle(
                              color: Color(0xFF627EEA),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_walletBalance.toStringAsFixed(3)} ETH',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Wallet',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(height: 30, width: 1, color: Colors.grey.shade300),
                  // Reward Points
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$_rewardPoints pts',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Rewards',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.stars_rounded,
                            color: Colors.amber.shade600,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (!canEvolve)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Need ${requiredXP - widget.agent.xp} more XP to evolve',
                        style: GoogleFonts.poppins(
                          color: Colors.amber.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    canEvolve
                        ? () => _showEvolutionPaymentDialog(typeColor)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canEvolve ? Colors.amber.shade600 : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: canEvolve ? 4 : 0,
                  shadowColor: Colors.amber.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 22,
                      color: canEvolve ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      canEvolve
                          ? 'Evolve with NFT • ${_evolutionCostETH} ETH'
                          : 'Not Ready Yet',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: canEvolve ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
