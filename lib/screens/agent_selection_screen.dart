import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/pokeagent.dart';
import '../models/battle_models.dart';
import '../services/wallet_service.dart';
import '../services/battle_service.dart';
import 'interactive_battle_screen.dart';

class AgentSelectionScreen extends StatefulWidget {
  const AgentSelectionScreen({super.key});

  @override
  State<AgentSelectionScreen> createState() => _AgentSelectionScreenState();
}

class _AgentSelectionScreenState extends State<AgentSelectionScreen>
    with SingleTickerProviderStateMixin {
  PokeAgent? _selectedAgent;
  bool _isLoading = false;
  bool _searchingOpponent = false;
  String _searchingText = 'Searching for opponent';
  late AnimationController _searchAnimController;

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    final battleService = Provider.of<BattleService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        title: Text(
          '⚔️ Select Your Pokémon',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Wallet Connection Status
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      walletService.isConnected
                          ? [Colors.green.shade700, Colors.green.shade900]
                          : [Colors.red.shade700, Colors.red.shade900],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (walletService.isConnected
                            ? Colors.green
                            : Colors.red)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    walletService.isConnected
                        ? Icons.account_balance_wallet
                        : Icons.warning,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      walletService.isConnected
                          ? '🎮 ${walletService.shortAddress}'
                          : '⚠️ Connect wallet to battle',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (!walletService.isConnected)
                    ElevatedButton(
                      onPressed: _connectWallet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Connect',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Agent Selection
          Expanded(
            child: FutureBuilder<List<PokeAgent>>(
              future: battleService.getUserAgents(walletService.walletAddress!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.amber),
                        const SizedBox(height: 16),
                        Text(
                          'Loading your Pokémon...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('Agent loading error: ${snapshot.error}');
                }

                final agents = snapshot.data ?? [];

                if (agents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.catching_pokemon,
                          size: 64,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Pokémon found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mint a Pokémon to start battling',
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    final agent = agents[index];
                    final isSelected = _selectedAgent?.id == agent.id;

                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedAgent = agent);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  isSelected
                                      ? [
                                        const Color(0xFFFFD700),
                                        const Color(0xFFFFA500),
                                      ]
                                      : [
                                        const Color(0xFF1E2749),
                                        const Color(0xFF2A3F5F),
                                      ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.amber
                                      : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected ? Colors.amber : Colors.blue)
                                    .withOpacity(0.3),
                                blurRadius: isSelected ? 20 : 8,
                                spreadRadius: isSelected ? 3 : 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Agent Image
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Stack(
                                      children: [
                                        if (agent.displayImageUrl.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Image.network(
                                              agent.displayImageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                          Colors.amber,
                                                        ),
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons.catching_pokemon,
                                                    color: Colors.white54,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        if (agent.displayImageUrl.isEmpty)
                                          const Center(
                                            child: Icon(
                                              Icons.catching_pokemon,
                                              color: Colors.white54,
                                              size: 50,
                                            ),
                                          ),
                                        // Selection indicator
                                        if (isSelected)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Agent Info
                                Text(
                                  agent.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected
                                            ? Colors.black87
                                            : Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lv ${agent.level} • ${agent.type}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        isSelected
                                            ? Colors.black54
                                            : Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatChip(
                                      'HP',
                                      agent.stats['hp']?.toString() ?? '0',
                                      isSelected,
                                    ),
                                    _buildStatChip(
                                      'ATK',
                                      agent.stats['attack']?.toString() ?? '0',
                                      isSelected,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Battle Button
          if (_selectedAgent != null && walletService.isConnected)
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A0E27), Colors.black],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchingOpponent)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AnimatedBuilder(
                            animation: _searchAnimController,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _searchingText,
                                        style: GoogleFonts.poppins(
                                          color: Colors.amber,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '...' *
                                            ((_searchAnimController.value * 3)
                                                    .toInt() %
                                                4),
                                        style: GoogleFonts.poppins(
                                          color: Colors.amber,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.amber,
                                    ),
                                    backgroundColor: Colors.white24,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _startBattle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.amber.withOpacity(0.5),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.flash_on, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        'FIND BATTLE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black26 : Colors.white24,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.black38 : Colors.white38,
          width: 1,
        ),
      ),
      child: Text(
        '$label $value',
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }

  Future<void> _connectWallet() async {
    final walletService = Provider.of<WalletService>(context, listen: false);
    final success = await walletService.connectWallet();
    if (success && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wallet connected successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _startBattle() async {
    if (_selectedAgent == null) return;

    setState(() {
      _isLoading = true;
      _searchingOpponent = true;
    });

    try {
      final battleService = Provider.of<BattleService>(context, listen: false);

      // Simulate searching for opponent
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _searchingText = 'Matching with opponent');
      }

      // Create battle on-chain
      final battleId = await battleService.createBattle(
        _selectedAgent!.id.hashCode.abs(),
      );

      if (mounted) {
        setState(() => _searchingText = 'Opponent found! Preparing arena');
      }
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate random opponent from available Pokemon
      final allOpponents = [
        BattleAgent(
          tokenId: 101,
          name: 'Blastoise',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png',
          level: 45 + math.Random().nextInt(10),
          elementType: 'Water',
          hp: 130,
          attack: 80,
          defense: 85,
          speed: 70,
        ),
        BattleAgent(
          tokenId: 102,
          name: 'Venusaur',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png',
          level: 45 + math.Random().nextInt(10),
          elementType: 'Grass',
          hp: 125,
          attack: 75,
          defense: 80,
          speed: 75,
        ),
        BattleAgent(
          tokenId: 103,
          name: 'Pikachu',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
          level: 40 + math.Random().nextInt(10),
          elementType: 'Electric',
          hp: 100,
          attack: 85,
          defense: 60,
          speed: 95,
        ),
        BattleAgent(
          tokenId: 104,
          name: 'Gyarados',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/130.png',
          level: 50 + math.Random().nextInt(10),
          elementType: 'Water',
          hp: 140,
          attack: 95,
          defense: 75,
          speed: 80,
        ),
        BattleAgent(
          tokenId: 105,
          name: 'Dragonite',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/149.png',
          level: 55 + math.Random().nextInt(10),
          elementType: 'Fire',
          hp: 135,
          attack: 100,
          defense: 85,
          speed: 85,
        ),
        BattleAgent(
          tokenId: 106,
          name: 'Mewtwo',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png',
          level: 60 + math.Random().nextInt(15),
          elementType: 'Electric',
          hp: 150,
          attack: 110,
          defense: 90,
          speed: 100,
        ),
        BattleAgent(
          tokenId: 107,
          name: 'Articuno',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/144.png',
          level: 50 + math.Random().nextInt(10),
          elementType: 'Water',
          hp: 120,
          attack: 80,
          defense: 95,
          speed: 85,
        ),
        BattleAgent(
          tokenId: 108,
          name: 'Zapdos',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/145.png',
          level: 50 + math.Random().nextInt(10),
          elementType: 'Electric',
          hp: 120,
          attack: 90,
          defense: 80,
          speed: 95,
        ),
      ];

      // Randomly select opponent
      final randomOpponent =
          allOpponents[math.Random().nextInt(allOpponents.length)];

      if (mounted) {
        // Navigate to interactive battle screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => InteractiveBattleScreen(
                  battleId: battleId,
                  myAgent: _selectedAgent!,
                  opponentAgent: randomOpponent,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to start battle: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchingOpponent = false;
          _searchingText = 'Searching for opponent';
        });
      }
    }
  }
}
