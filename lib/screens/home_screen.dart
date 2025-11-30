import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../models/pokeagent.dart';
import '../models/battle_models.dart';
import '../services/wallet_service.dart';
import '../services/battle_service.dart';
import '../services/user_stats_service.dart';
import '../services/daily_challenge_service.dart';
import '../widgets/pokeagent_card.dart';
import '../data/pokemon_data.dart';
import 'mint_screen.dart';
import 'train_screen.dart';
import 'flutter_3d_battle_screen.dart';
import 'evolution_screen.dart';
import 'regions_screen.dart';
import 'favorites_screen.dart';
import 'account_screen.dart';
import 'add_tokens_screen.dart';
import 'marketplace_screen.dart';
import 'create_listing_screen.dart';
import 'leaderboard_screen.dart';
import 'stats_screen.dart';
import 'daily_challenges_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<PokeAgent> _agents = [];
  List<Map<String, dynamic>> _caughtPokemon = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAgents();
    _loadCaughtPokemon();
    _initializeUserStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh caught Pokemon when app comes back to foreground
      _loadCaughtPokemon();
    }
  }

  Future<void> _initializeUserStats() async {
    // Initialize stats with starter Pokémon count from battle_service mock data
    final statsService = Provider.of<UserStatsService>(context, listen: false);
    await statsService.initializeWithMockData();
  }

  Future<void> _loadCaughtPokemon() async {
    final prefs = await SharedPreferences.getInstance();
    final caughtList = prefs.getStringList('caught_pokemon') ?? [];

    setState(() {
      _caughtPokemon =
          caughtList.map((p) => jsonDecode(p) as Map<String, dynamic>).toList();
    });

    // Sync Pokemon count with UserStatsService for account screen
    final statsService = Provider.of<UserStatsService>(context, listen: false);
    await statsService.setOwnedPokemonCount(
      _caughtPokemon.length + _agents.length,
    );
  }

  Future<void> _loadAgents() async {
    final prefs = await SharedPreferences.getInstance();
    final agentsJson = prefs.getStringList('agents') ?? [];

    setState(() {
      _agents =
          agentsJson
              .map((json) => PokeAgent.fromJson(jsonDecode(json)))
              .toList();
      _isLoading = false;
    });

    // Sync Pokemon count with UserStatsService for account screen
    final statsService = Provider.of<UserStatsService>(context, listen: false);
    await statsService.setOwnedPokemonCount(
      _caughtPokemon.length + _agents.length,
    );
  }

  Future<void> _saveAgents() async {
    final prefs = await SharedPreferences.getInstance();
    final agentsJson =
        _agents.map((agent) => jsonEncode(agent.toJson())).toList();
    await prefs.setStringList('agents', agentsJson);

    // Sync Pokemon count with UserStatsService
    final statsService = Provider.of<UserStatsService>(context, listen: false);
    await statsService.setOwnedPokemonCount(
      _caughtPokemon.length + _agents.length,
    );
  }

  void _addAgent(PokeAgent agent) {
    setState(() {
      _agents.add(agent);
    });
    _saveAgents();
  }

  void _updateAgent(PokeAgent updatedAgent) {
    setState(() {
      final index = _agents.indexWhere((a) => a.id == updatedAgent.id);
      if (index != -1) {
        _agents[index] = updatedAgent;
      }
    });
    _saveAgents();
  }

  void _deleteAgent(PokeAgent agent) {
    setState(() {
      _agents.removeWhere((a) => a.id == agent.id);
    });
    _saveAgents();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Agent Deleted',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${agent.name} has been removed',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _agents.add(agent);
            });
            _saveAgents();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);

    // Define pages for bottom navigation
    final List<Widget> _pages = [
      _buildPokedexPage(walletService),
      _buildRegionsPage(),
      _buildFavoritesPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Pokemon type colors
  final Map<String, Color> _typeColors = {
    'Fire': const Color(0xFFFB6C6C),
    'Water': const Color(0xFF77BDFE),
    'Grass': const Color(0xFF48D0B0),
    'Electric': const Color(0xFFFFCE4B),
    'Normal': const Color(0xFFA0A29F),
    'Ice': const Color(0xFF8ED8D8),
    'Fighting': const Color(0xFFD56723),
    'Poison': const Color(0xFFB97FC9),
    'Ground': const Color(0xFFD9B34A),
    'Flying': const Color(0xFFA890F0),
    'Psychic': const Color(0xFFFA6B8A),
    'Bug': const Color(0xFFA8B820),
    'Rock': const Color(0xFFB8A038),
    'Ghost': const Color(0xFF705898),
    'Dragon': const Color(0xFF7038F8),
    'Dark': const Color(0xFF705848),
    'Steel': const Color(0xFFB8B8D0),
    'Fairy': const Color(0xFFEE99AC),
  };

  // Pokedex Page (Main Page)
  Widget _buildPokedexPage(WalletService walletService) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(walletService),
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFFCD3131),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading agents...',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadAgents();
        await _loadCaughtPokemon();
      },
      color: const Color(0xFFCD3131),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caught Pokemon Section
            if (_caughtPokemon.isNotEmpty) ...[
              _buildCaughtPokemonSection(),
              const SizedBox(height: 16),
            ],
            // Agents Grid
            _buildAgentGridSection(),
            // Quick Access Buttons (below agent cards)
            _buildQuickAccessMenu(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessMenu() {
    return Consumer<DailyChallengeService>(
      builder: (context, challengeService, child) {
        final unclaimedCount =
            challengeService.challenges
                .where((c) => c.isCompleted && !c.isRewardClaimed)
                .length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Quick Access',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF303943),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Buttons Row
              Row(
                children: [
                  // Leaderboard Button
                  Expanded(
                    child: _buildQuickAccessButton(
                      emoji: '🏆',
                      label: 'Leaderboard',
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Stats Button
                  Expanded(
                    child: _buildQuickAccessButton(
                      emoji: '📊',
                      label: 'Stats',
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Daily Challenges Button
                  Expanded(
                    child: Stack(
                      children: [
                        _buildQuickAccessButton(
                          emoji: '🎯',
                          label: 'Challenges',
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DailyChallengesScreen(),
                              ),
                            );
                          },
                        ),
                        if (unclaimedCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                '$unclaimedCount',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessButton({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaughtPokemonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCD3131).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.catching_pokemon,
                      color: Color(0xFFCD3131),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Caught Pokemon',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF303943),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCD3131).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_caughtPokemon.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFCD3131),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _caughtPokemon.length,
            itemBuilder: (context, index) {
              final pokemon = _caughtPokemon[index];
              final types = (pokemon['types'] as List<dynamic>?) ?? ['Normal'];
              final primaryType = types.first.toString();
              final color = _typeColors[primaryType] ?? const Color(0xFFA0A29F);

              return FadeInRight(
                delay: Duration(milliseconds: index * 50),
                child: _buildCaughtPokemonCard(pokemon, color),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCaughtPokemonCard(Map<String, dynamic> pokemon, Color color) {
    final pokemonId = pokemon['id'] as int;
    final pokemonName = pokemon['name'] as String;

    return GestureDetector(
      onTap: () => _showCaughtPokemonDetails(pokemon, color),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pokeball background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.catching_pokemon,
                size: 80,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            // Caught badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.white, size: 16),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${pokemonId.toString().padLeft(3, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Pokemon Image
                  Center(
                    child: Image.network(
                      PokemonData.getPngUrl(pokemonName),
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.catching_pokemon,
                            size: 50,
                            color: Colors.white.withOpacity(0.7),
                          ),
                    ),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    pokemonName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentGridSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_caughtPokemon.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF303943).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Color(0xFF303943),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Agents',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF303943),
                    ),
                  ),
                ],
              ),
            ),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _agents.length + 1,
            itemBuilder: (context, index) {
              if (index == _agents.length) {
                return _buildAddNewCard();
              }

              final agent = _agents[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 50),
                child: Dismissible(
                  key: Key(agent.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_sweep_rounded,
                          color: Colors.red.shade500,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteDialog(agent);
                  },
                  onDismissed: (direction) {
                    _deleteAgent(agent);
                  },
                  child: PokeAgentCard(
                    agent: agent,
                    onTap: () => _showAgentOptions(agent),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(PokeAgent agent) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F36),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Delete Agent?',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete ${agent.name}?\nThis action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red.shade500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Regions Page
  Widget _buildRegionsPage() {
    return SafeArea(
      child: Column(
        children: [
          _buildSimpleHeader('Regions'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Regions',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore different regions',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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

  // Favorites Page
  Widget _buildFavoritesPage() {
    final favoriteAgents = _agents.where((agent) => agent.isFavorite).toList();

    return SafeArea(
      child: Column(
        children: [
          _buildSimpleHeader('Favorites'),
          Expanded(
            child:
                favoriteAgents.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Favorites Yet',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your favorite agents here',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: favoriteAgents.length,
                      itemBuilder: (context, index) {
                        final agent = favoriteAgents[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: index * 50),
                          child: PokeAgentCard(
                            agent: agent,
                            onTap: () => _showAgentOptions(agent),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WalletService walletService) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInLeft(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My PokéAgents',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFCD3131).withValues(alpha: 0.15),
                            const Color(0xFFCD3131).withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFCD3131).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.catching_pokemon,
                            size: 14,
                            color: Color(0xFFCD3131),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_agents.length + _caughtPokemon.length} collected',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFCD3131),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FadeInRight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Balance display
                    if (walletService.isConnected)
                      GestureDetector(
                        onTap: () => _showBalanceDetails(walletService),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFD700),
                                const Color(0xFFFFA500),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFD700,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '${walletService.formattedBalance} POKO',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Wallet connection status
                    walletService.isConnected
                        ? GestureDetector(
                          onTap: () => _showWalletDetailsSheet(walletService),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  walletService.shortAddress,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        )
                        : ElevatedButton.icon(
                          onPressed: () async {
                            await walletService.connectWallet();
                          },
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                          ),
                          label: Text(
                            'Connect',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCD3131),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBalanceDetails(WalletService walletService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Balance card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFD700),
                          const Color(0xFFFFA500),
                          const Color(0xFFFF8C00),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'POKO Balance',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          walletService.formattedBalance,
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Costs info
                  Text(
                    'Token Costs',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCostRow('🎯 Mint Agent', '50 POKO'),
                  _buildCostRow('⚔️ Battle', '10 POKO'),
                  _buildCostRow('✨ Evolve', '100 POKO'),
                  _buildCostRow('📚 Training', '5 POKO'),
                  _buildCostRow('🎮 Catch Pokémon', '20 POKO'),
                  const SizedBox(height: 24),
                  // Add Tokens Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTokensScreen(),
                          ),
                        );
                      },
                      icon: const Text('➕', style: TextStyle(fontSize: 18)),
                      label: Text(
                        'Add POKO Tokens',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
    );
  }

  void _showWalletDetailsSheet(WalletService walletService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Wallet Info Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.green.shade600,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Connected',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  walletService.walletName ?? 'Unknown',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Wallet Address Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Address',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                walletService.walletAddress ?? '',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: walletService.walletAddress ?? '',
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Address copied!',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.copy,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Balances Row - Crypto and POKO
                  Row(
                    children: [
                      // Crypto Balance Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _getCryptoGradient(
                                walletService.walletName,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _getCryptoGradient(
                                  walletService.walletName,
                                )[0].withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    walletService.cryptoIcon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    walletService.cryptoSymbol,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                walletService.formattedCryptoBalance,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _getCryptoUsdValue(walletService),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // POKO Balance Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFFD700),
                                const Color(0xFFFFA500),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '🪙',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'POKO',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                walletService.formattedBalance,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Game Tokens',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddTokensScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: Text(
                            'Add Tokens',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await walletService.disconnectWallet();
                          },
                          icon: Icon(
                            Icons.logout,
                            size: 20,
                            color: Colors.red.shade600,
                          ),
                          label: Text(
                            'Disconnect',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            ),
          ),
    );
  }

  // Helper method to get crypto gradient colors based on wallet type
  List<Color> _getCryptoGradient(String? walletName) {
    if (walletName == null) {
      return [const Color(0xFF627EEA), const Color(0xFF4F6BDB)]; // ETH blue
    }
    if (walletName.toLowerCase().contains('freighter')) {
      return [
        const Color(0xFF000000),
        const Color(0xFF333333),
      ]; // Stellar black
    }
    if (walletName.toLowerCase().contains('phantom')) {
      return [
        const Color(0xFF9945FF),
        const Color(0xFF7B3FE4),
      ]; // Solana purple
    }
    if (walletName.toLowerCase().contains('metamask')) {
      return [
        const Color(0xFFF6851B),
        const Color(0xFFE2761B),
      ]; // MetaMask orange
    }
    return [
      const Color(0xFF627EEA),
      const Color(0xFF4F6BDB),
    ]; // Default ETH blue
  }

  // Helper method to calculate USD value based on crypto type
  String _getCryptoUsdValue(WalletService walletService) {
    final balance = walletService.cryptoBalance;
    final symbol = walletService.cryptoSymbol;

    // Mock exchange rates
    double rate = 0;
    if (symbol == 'ETH') {
      rate = 3245.50; // ETH to USD
    } else if (symbol == 'XLM') {
      rate = 0.12; // XLM to USD
    } else if (symbol == 'SOL') {
      rate = 98.75; // SOL to USD
    }

    final usdValue = balance * rate;
    return '≈ \$${usdValue.toStringAsFixed(2)} USD';
  }

  Widget _buildCostRow(String action, String cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cost,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF8C00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCard() {
    return FadeInUp(
      delay: Duration(milliseconds: _agents.length * 50),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MintScreen()),
          );
          if (result != null && result is PokeAgent) {
            _addAgent(result);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFCD3131).withValues(alpha: 0.08),
                const Color(0xFFCD3131).withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFCD3131).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCD3131).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFCD3131).withOpacity(0.2),
                      const Color(0xFFCD3131).withOpacity(0.35),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCD3131).withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 38,
                  color: Color(0xFFCD3131),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Add New',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFCD3131),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to mint agent',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAgentOptions(PokeAgent agent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  agent.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                _buildOptionTile(
                  icon: Icons.chat_bubble_rounded,
                  iconColor: const Color(0xFFCD3131),
                  title: 'Train',
                  subtitle: 'Chat and increase XP',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TrainScreen(
                              agent: agent,
                              onAgentUpdate: _updateAgent,
                            ),
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.sports_kabaddi_rounded,
                  iconColor: Colors.orange,
                  title: 'Battle',
                  subtitle: 'Fight other agents',
                  onTap: () async {
                    Navigator.pop(context);
                    await _startBattleWithAgent(agent);
                  },
                ),
                if (agent.canEvolve)
                  _buildOptionTile(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: Colors.amber,
                    title: 'Evolve',
                    subtitle: 'Transform your agent',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EvolutionScreen(
                                agent: agent,
                                onAgentUpdate: _updateAgent,
                              ),
                        ),
                      );
                    },
                  ),
                _buildOptionTile(
                  icon: Icons.storefront_rounded,
                  iconColor: Colors.blue,
                  title: 'Sell on Marketplace',
                  subtitle: 'List your agent for sale',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateListingScreen(agent: agent),
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.delete_rounded,
                  iconColor: Colors.red,
                  title: 'Delete',
                  subtitle: 'Remove this agent',
                  onTap: () {
                    Navigator.pop(context);
                    _deleteAgent(agent);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
    );
  }

  void _showCaughtPokemonDetails(Map<String, dynamic> pokemon, Color color) {
    final pokemonId = pokemon['id'] as int;
    final pokemonName = pokemon['name'] as String;
    final types = (pokemon['types'] as List<dynamic>?) ?? ['Normal'];
    final caughtAt = pokemon['caughtAt'] as String?;

    DateTime? caughtDate;
    if (caughtAt != null) {
      try {
        caughtDate = DateTime.parse(caughtAt);
      } catch (e) {
        caughtDate = null;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.9), color],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Pokemon Image
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    PokemonData.getPngUrl(pokemonName),
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.catching_pokemon,
                          size: 100,
                          color: Colors.white.withOpacity(0.7),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                // Pokemon Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pokemonName,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#${pokemonId.toString().padLeft(3, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Types
                Wrap(
                  spacing: 8,
                  children:
                      types.map<Widget>((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                if (caughtDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Caught on ${caughtDate.day}/${caughtDate.month}/${caughtDate.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _convertToAgentForBattle(pokemon, color);
                        },
                        icon: const Icon(Icons.sports_kabaddi, size: 20),
                        label: Text(
                          'Use in Battle',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white,
                          foregroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _convertToAgentForMarketplace(pokemon, color);
                        },
                        icon: const Icon(Icons.storefront, size: 20),
                        label: Text(
                          'Sell',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarketplaceScreen(),
              ),
            );
            // Reload agents when returning from marketplace (in case of purchase)
            await _loadAgents();
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegionsScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFCD3131),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon, size: 24),
            label: 'Pokedex',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_rounded, size: 24),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded, size: 24),
            label: 'Regions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded, size: 24),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 24),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Future<void> _startBattleWithAgent(PokeAgent selectedAgent) async {
    final battleService = Provider.of<BattleService>(context, listen: false);
    final walletService = Provider.of<WalletService>(context, listen: false);

    if (!walletService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please connect your wallet first!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user has enough balance for battle
    if (!walletService.hasEnoughBalance(WalletService.battleCost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Insufficient balance! Need ${WalletService.battleCost.toInt()} POKO for battle',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Finding opponent...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '-${WalletService.battleCost.toInt()} POKO',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      // Deduct battle cost
      await walletService.deductTokens(WalletService.battleCost);

      // Create battle - use hashCode for string IDs
      final battleId = await battleService.createBattle(
        selectedAgent.id.hashCode.abs(),
      );

      // Generate random opponent
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

      final randomOpponent =
          allOpponents[math.Random().nextInt(allOpponents.length)];

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to battle
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => Flutter3DBattleScreen(
                  battleId: battleId,
                  myAgent: selectedAgent,
                  opponentAgent: randomOpponent,
                ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Refund on failure
      await walletService.addTokens(WalletService.battleCost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to start battle: $e (Tokens refunded)',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Convert caught Pokemon to PokeAgent for battles
  Future<void> _convertToAgentForBattle(
    Map<String, dynamic> pokemon,
    Color color,
  ) async {
    try {
      // Create PokeAgent from caught Pokemon data
      final newAgent = PokeAgent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: pokemon['name'] ?? 'Unknown',
        type: (pokemon['types'] as List?)?.first ?? 'Normal',
        imageUrl: pokemon['imageUrl'] ?? '',
        xp: 0,
        evolutionStage: 1,
        personality: _getRandomPersonality(),
        stats: _generateStatsFromPokemon(pokemon),
        createdAt: DateTime.now(),
        mood: 'excited',
        moodLevel: 90,
      );

      // Remove from caught Pokemon list
      setState(() {
        _caughtPokemon.removeWhere(
          (p) =>
              p['id'] == pokemon['id'] && p['caughtAt'] == pokemon['caughtAt'],
        );
      });

      // Save caught Pokemon list
      final prefs = await SharedPreferences.getInstance();
      final caughtJson = _caughtPokemon.map((p) => jsonEncode(p)).toList();
      await prefs.setStringList('caught_pokemon', caughtJson);

      // Add to agents list
      _addAgent(newAgent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${newAgent.name} is now ready for battle!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );

        // Show success message - agent is now in the main list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to convert Pokemon: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Convert caught Pokemon to PokeAgent for marketplace
  Future<void> _convertToAgentForMarketplace(
    Map<String, dynamic> pokemon,
    Color color,
  ) async {
    try {
      // Create PokeAgent from caught Pokemon data
      final newAgent = PokeAgent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: pokemon['name'] ?? 'Unknown',
        type: (pokemon['types'] as List?)?.first ?? 'Normal',
        imageUrl: pokemon['imageUrl'] ?? '',
        xp: 0,
        evolutionStage: 1,
        personality: _getRandomPersonality(),
        stats: _generateStatsFromPokemon(pokemon),
        createdAt: DateTime.now(),
        mood: 'happy',
        moodLevel: 80,
      );

      // Remove from caught Pokemon list
      setState(() {
        _caughtPokemon.removeWhere(
          (p) =>
              p['id'] == pokemon['id'] && p['caughtAt'] == pokemon['caughtAt'],
        );
      });

      // Save caught Pokemon list
      final prefs = await SharedPreferences.getInstance();
      final caughtJson = _caughtPokemon.map((p) => jsonEncode(p)).toList();
      await prefs.setStringList('caught_pokemon', caughtJson);

      // Add to agents list
      _addAgent(newAgent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${newAgent.name} is now ready to sell!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to marketplace with this agent
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateListingScreen(agent: newAgent),
          ),
        ).then((_) {
          // Refresh agents after returning from listing screen
          _loadAgents();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to convert Pokemon: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper: Generate random personality
  String _getRandomPersonality() {
    final personalities = [
      'Brave',
      'Timid',
      'Jolly',
      'Serious',
      'Calm',
      'Hardy',
      'Gentle',
      'Adamant',
      'Modest',
      'Careful',
    ];
    return personalities[math.Random().nextInt(personalities.length)];
  }

  // Helper: Generate stats based on Pokemon data
  Map<String, int> _generateStatsFromPokemon(Map<String, dynamic> pokemon) {
    final random = math.Random();
    final baseStat = 50;
    final variance = 30;

    // Use Pokemon ID to seed some consistency (same species = similar stats)
    final seed = (pokemon['id'] ?? random.nextInt(1000)) as int;

    return {
      'hp': (baseStat + (seed % 20) + random.nextInt(variance)).toInt(),
      'attack':
          (baseStat + ((seed * 2) % 20) + random.nextInt(variance)).toInt(),
      'defense':
          (baseStat + ((seed * 3) % 20) + random.nextInt(variance)).toInt(),
      'speed':
          (baseStat + ((seed * 4) % 20) + random.nextInt(variance)).toInt(),
      'special':
          (baseStat + ((seed * 5) % 20) + random.nextInt(variance)).toInt(),
    };
  }
}
