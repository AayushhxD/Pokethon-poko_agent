import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../models/pokeagent.dart';
import '../utils/theme.dart';
import 'train_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  List<PokeAgent> _favoriteAgents = [];
  bool _isLoading = true;

  // Pokemon dummy data collection
  List<Map<String, dynamic>> _samplePokemon = [
    {
      'id': '6',
      'name': 'Charizard',
      'level': 100,
      'types': ['Fire', 'Flying'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png',
      'backgroundColor': const Color(0xFFFFB366),
    },
    {
      'id': '3',
      'name': 'Venusaur',
      'level': 70,
      'types': ['Grass', 'Poison'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png',
      'backgroundColor': const Color(0xFF90C878),
    },
    {
      'id': '151',
      'name': 'Mew',
      'level': 200,
      'types': ['Psychic'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/151.png',
      'backgroundColor': const Color(0xFFFF9AB8),
    },
    {
      'id': '448',
      'name': 'Lucario',
      'level': 85,
      'types': ['Fighting', 'Steel'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/448.png',
      'backgroundColor': const Color(0xFFD04164),
    },
    {
      'id': '497',
      'name': 'Serperior',
      'level': 92,
      'types': ['Grass'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/497.png',
      'backgroundColor': const Color(0xFF90C878),
    },
    {
      'id': '25',
      'name': 'Pikachu',
      'level': 65,
      'types': ['Electric'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
      'backgroundColor': const Color(0xFFF4D03F),
    },
    {
      'id': '94',
      'name': 'Gengar',
      'level': 88,
      'types': ['Ghost', 'Poison'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/94.png',
      'backgroundColor': const Color(0xFF7C538C),
    },
    {
      'id': '130',
      'name': 'Gyarados',
      'level': 95,
      'types': ['Water', 'Flying'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/130.png',
      'backgroundColor': const Color(0xFF4A90E2),
    },
    {
      'id': '143',
      'name': 'Snorlax',
      'level': 78,
      'types': ['Normal'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/143.png',
      'backgroundColor': const Color(0xFF919AA2),
    },
    {
      'id': '248',
      'name': 'Tyranitar',
      'level': 93,
      'types': ['Rock', 'Dark'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/248.png',
      'backgroundColor': const Color(0xFF9C8179),
    },
    {
      'id': '282',
      'name': 'Gardevoir',
      'level': 87,
      'types': ['Psychic', 'Fairy'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/282.png',
      'backgroundColor': const Color(0xFFFF9AB8),
    },
    {
      'id': '445',
      'name': 'Garchomp',
      'level': 96,
      'types': ['Dragon', 'Ground'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/445.png',
      'backgroundColor': const Color(0xFF0C69C8),
    },
    {
      'id': '9',
      'name': 'Blastoise',
      'level': 82,
      'types': ['Water'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png',
      'backgroundColor': const Color(0xFF4A90E2),
    },
    {
      'id': '38',
      'name': 'Ninetales',
      'level': 74,
      'types': ['Fire'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/38.png',
      'backgroundColor': const Color(0xFFFF9C54),
    },
    {
      'id': '658',
      'name': 'Greninja',
      'level': 91,
      'types': ['Water', 'Dark'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/658.png',
      'backgroundColor': const Color(0xFF4A90E2),
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteAgents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFavoriteAgents() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      final agentsJson = prefs.getStringList('agents') ?? [];

      final allAgents =
          agentsJson
              .map((json) => PokeAgent.fromJson(jsonDecode(json)))
              .toList();

      if (mounted) {
        setState(() {
          _favoriteAgents =
              allAgents.where((agent) => agent.isFavorite).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAgents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentsJson =
          _favoriteAgents.map((agent) => jsonEncode(agent.toJson())).toList();
      await prefs.setStringList('agents', agentsJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  void _removeFromFavorites(int index) {
    if (index < 0 || index >= _samplePokemon.length) return;

    final removedPokemon = _samplePokemon[index];

    setState(() {
      _samplePokemon.removeAt(index);
    });

    _showSnackBar(
      message: '${removedPokemon['name']} removed from favorites',
      backgroundColor: const Color(0xFFCD3131),
      icon: Icons.check_circle,
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.white,
        onPressed: () {
          setState(() {
            _samplePokemon.insert(index, removedPokemon);
          });
        },
      ),
    );
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    IconData? icon,
    SnackBarAction? action,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: action,
      ),
    );
  }

  void _showPokemonOptions(Map<String, dynamic> pokemon) {
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
                  pokemon['name'],
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
                    _showPokemonDetails(pokemon);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.sports_kabaddi_rounded,
                  iconColor: Colors.orange,
                  title: 'Battle',
                  subtitle: 'Fight other Pokemon',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar(
                      message: 'Battle feature coming soon!',
                      backgroundColor: Colors.orange,
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.info_rounded,
                  iconColor: Colors.blue,
                  title: 'Details',
                  subtitle: 'View Pokemon information',
                  onTap: () {
                    Navigator.pop(context);
                    _showPokemonInfo(pokemon);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
    );
  }

  void _showPokemonInfo(Map<String, dynamic> pokemon) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: pokemon['backgroundColor'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: pokemon['imageUrl'],
                      placeholder:
                          (context, url) => const CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pokemon['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pokemon['backgroundColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level ${pokemon['level']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (pokemon['types'] as List<String>).map((type) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              type,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD3131),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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

  void _showPokemonDetails(Map<String, dynamic> pokemon) {
    // Create a dummy PokeAgent from Pokemon data for training
    final dummyAgent = PokeAgent(
      id: pokemon['id'],
      name: pokemon['name'],
      type: pokemon['types'][0], // Use first type
      imageUrl: pokemon['imageUrl'],
      xp: pokemon['level'] * 100, // Convert level to XP
      evolutionStage: 1,
      personality: 'Curious',
      mood: 'excited',
      moodLevel: 85,
      isFavorite: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TrainScreen(
              agent: dummyAgent,
              onAgentUpdate: (updatedAgent) {
                // Since this is sample data, we don't save updates
                // But we could show a message that training is simulated
                _showSnackBar(
                  message: 'Training completed! (Sample Pokemon)',
                  backgroundColor: const Color(0xFF4CAF50),
                );
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  _isLoading
                      ? _buildLoadingState()
                      : _samplePokemon.isEmpty
                      ? _buildEmptyState()
                      : _buildFavoritesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Favorites',
              style: GoogleFonts.poppins(
                color: const Color(0xFF2E3A59),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFCD3131).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFCD3131).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFCD3131),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_samplePokemon.length}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFCD3131),
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
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFCD3131),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading favorites...',
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _samplePokemon.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final pokemon = _samplePokemon[index];
        return FadeInUp(
          key: ValueKey('${pokemon['id']}-$index'),
          delay: Duration(milliseconds: index * 50),
          duration: const Duration(milliseconds: 400),
          child: _buildPokemonCard(pokemon, index),
        );
      },
    );
  }

  Widget _buildPokemonCard(Map<String, dynamic> pokemon, int index) {
    final backgroundColor = pokemon['backgroundColor'] as Color;
    final types = pokemon['types'] as List<String>;

    return Dismissible(
      key: Key(
        'dismissible-${pokemon['id']}-$index-${DateTime.now().millisecondsSinceEpoch}',
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCD3131), Color(0xFFFF6B6B)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_sweep_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(pokemon),
      onDismissed: (direction) => _removeFromFavorites(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor.withOpacity(0.7), backgroundColor],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showPokemonOptions(pokemon),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildPokemonImage(pokemon),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPokemonInfo(pokemon, types)),
                  _buildFavoriteIcon(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonImage(Map<String, dynamic> pokemon) {
    return Hero(
      tag: 'pokemon-${pokemon['id']}',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: pokemon['imageUrl'],
            fit: BoxFit.contain,
            placeholder:
                (context, url) => Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
            errorWidget:
                (context, url, error) => Icon(
                  Icons.catching_pokemon,
                  color: Colors.white.withOpacity(0.5),
                  size: 40,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonInfo(Map<String, dynamic> pokemon, List<String> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '#${pokemon['id'].toString().padLeft(3, '0')}',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          pokemon['name'],
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: types.map((type) => _buildTypeBadge(type)).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeColor(type),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(type), color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            type,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.favorite, color: Colors.white, size: 24),
    );
  }

  Future<bool?> _showDeleteConfirmation(Map<String, dynamic> pokemon) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCD3131).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFCD3131),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Remove from Favorites?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to remove ${pokemon['name']} from your favorites?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCD3131),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Remove',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: Color(0xFFCD3131),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Favorites Yet',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start adding your favorite Pokémon\nto see them here!',
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final typeColors = {
      'fire': const Color(0xFFFF9C54),
      'water': const Color(0xFF4A90E2),
      'grass': const Color(0xFF63BC5A),
      'electric': const Color(0xFFF4D03F),
      'psychic': const Color(0xFFFA92B2),
      'fighting': const Color(0xFFD04164),
      'steel': const Color(0xFF5A8EA2),
      'poison': const Color(0xFFAB6AC8),
      'flying': const Color(0xFF89AAE3),
      'dragon': const Color(0xFF0C69C8),
      'dark': const Color(0xFF5A5465),
      'ghost': const Color(0xFF7C538C),
      'rock': const Color(0xFF9C8179),
      'ground': const Color(0xFFD97845),
      'fairy': const Color(0xFFFFB1D5),
      'normal': const Color(0xFF919AA2),
    };
    return typeColors[type.toLowerCase()] ?? const Color(0xFF919AA2);
  }

  IconData _getTypeIcon(String type) {
    final typeIcons = {
      'fire': Icons.local_fire_department,
      'water': Icons.water_drop,
      'grass': Icons.grass,
      'electric': Icons.bolt,
      'psychic': Icons.psychology,
      'fighting': Icons.sports_martial_arts,
      'steel': Icons.shield,
      'poison': Icons.science,
      'flying': Icons.air,
      'dragon': Icons.whatshot,
      'dark': Icons.dark_mode,
      'ghost': Icons.auto_awesome,
      'rock': Icons.landscape,
      'ground': Icons.terrain,
      'fairy': Icons.star,
      'normal': Icons.circle,
    };
    return typeIcons[type.toLowerCase()] ?? Icons.circle;
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                Icons.explore_outlined,
                'Pokedex',
                false,
                () => Navigator.pop(context),
              ),
              _buildBottomNavItem(
                Icons.location_on_outlined,
                'Regions',
                false,
                () => Navigator.pop(context),
              ),
              _buildBottomNavItem(Icons.favorite, 'Favorites', true, () {}),
              _buildBottomNavItem(
                Icons.person_outline,
                'Account',
                false,
                () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return IconButton(
      onPressed: onTap,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFCD3131) : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive ? const Color(0xFFCD3131) : Colors.grey.shade400,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
    );
  }
}
