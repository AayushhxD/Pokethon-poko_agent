import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:convert';
import '../models/pokeagent.dart';
import '../models/battle_models.dart';
import 'train_screen.dart';
import 'flutter_3d_battle_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _samplePokemon = [
    {
      'id': '6',
      'name': 'Charizard',
      'level': 100,
      'types': ['Fire', 'Flying'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png',
      'backgroundColor': const Color(0xFFFFB366),
      'isOwned': true,
      'price': 0.05,
      'rarity': 'Legendary',
    },
    {
      'id': '3',
      'name': 'Venusaur',
      'level': 70,
      'types': ['Grass', 'Poison'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png',
      'backgroundColor': const Color(0xFF90C878),
      'isOwned': true,
      'price': 0.03,
      'rarity': 'Rare',
    },
    {
      'id': '151',
      'name': 'Mew',
      'level': 200,
      'types': ['Psychic'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/151.png',
      'backgroundColor': const Color(0xFFFF9AB8),
      'isOwned': false,
      'price': 0.15,
      'rarity': 'Mythical',
    },
    {
      'id': '448',
      'name': 'Lucario',
      'level': 85,
      'types': ['Fighting', 'Steel'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/448.png',
      'backgroundColor': const Color(0xFFD04164),
      'isOwned': false,
      'price': 0.04,
      'rarity': 'Rare',
    },
    {
      'id': '497',
      'name': 'Serperior',
      'level': 92,
      'types': ['Grass'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/497.png',
      'backgroundColor': const Color(0xFF90C878),
      'isOwned': true,
      'price': 0.025,
      'rarity': 'Common',
    },
    {
      'id': '25',
      'name': 'Pikachu',
      'level': 65,
      'types': ['Electric'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
      'backgroundColor': const Color(0xFFF4D03F),
      'isOwned': true,
      'price': 0.02,
      'rarity': 'Common',
    },
    {
      'id': '94',
      'name': 'Gengar',
      'level': 88,
      'types': ['Ghost', 'Poison'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/94.png',
      'backgroundColor': const Color(0xFF7C538C),
      'isOwned': false,
      'price': 0.035,
      'rarity': 'Rare',
    },
    {
      'id': '130',
      'name': 'Gyarados',
      'level': 95,
      'types': ['Water', 'Flying'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/130.png',
      'backgroundColor': const Color(0xFF4A90E2),
      'isOwned': false,
      'price': 0.045,
      'rarity': 'Rare',
    },
    {
      'id': '143',
      'name': 'Snorlax',
      'level': 78,
      'types': ['Normal'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/143.png',
      'backgroundColor': const Color(0xFF919AA2),
      'isOwned': true,
      'price': 0.03,
      'rarity': 'Rare',
    },
    {
      'id': '248',
      'name': 'Tyranitar',
      'level': 93,
      'types': ['Rock', 'Dark'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/248.png',
      'backgroundColor': const Color(0xFF9C8179),
      'isOwned': false,
      'price': 0.06,
      'rarity': 'Legendary',
    },
    {
      'id': '282',
      'name': 'Gardevoir',
      'level': 87,
      'types': ['Psychic', 'Fairy'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/282.png',
      'backgroundColor': const Color(0xFFFF9AB8),
      'isOwned': false,
      'price': 0.04,
      'rarity': 'Rare',
    },
    {
      'id': '445',
      'name': 'Garchomp',
      'level': 96,
      'types': ['Dragon', 'Ground'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/445.png',
      'backgroundColor': const Color(0xFF0C69C8),
      'isOwned': false,
      'price': 0.08,
      'rarity': 'Legendary',
    },
    {
      'id': '9',
      'name': 'Blastoise',
      'level': 82,
      'types': ['Water'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png',
      'backgroundColor': const Color(0xFF4A90E2),
      'isOwned': true,
      'price': 0.035,
      'rarity': 'Rare',
    },
    {
      'id': '38',
      'name': 'Ninetales',
      'level': 74,
      'types': ['Fire'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/38.png',
      'backgroundColor': const Color(0xFFFF9C54),
      'isOwned': false,
      'price': 0.03,
      'rarity': 'Rare',
    },
    {
      'id': '658',
      'name': 'Greninja',
      'level': 91,
      'types': ['Water', 'Dark'],
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/658.png',
      'backgroundColor': const Color(0xFF4A90E2),
      'isOwned': true,
      'price': 0.04,
      'rarity': 'Rare',
    },
  ];

  // Wallet balance (simulated - in production this comes from blockchain)
  double _walletBalance = 0.25; // ETH balance
  bool _isProcessingPayment = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadOwnedPokemon();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Load owned Pokemon state from SharedPreferences
  Future<void> _loadOwnedPokemon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownedIds = prefs.getStringList('owned_pokemon_ids') ?? [];

      setState(() {
        for (var pokemon in _samplePokemon) {
          if (ownedIds.contains(pokemon['id'].toString())) {
            pokemon['isOwned'] = true;
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading owned Pokemon: $e');
    }
  }

  /// Save owned Pokemon ID to SharedPreferences
  Future<void> _saveOwnedPokemon(String pokemonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ownedIds = prefs.getStringList('owned_pokemon_ids') ?? [];

      if (!ownedIds.contains(pokemonId)) {
        ownedIds.add(pokemonId);
        await prefs.setStringList('owned_pokemon_ids', ownedIds);
      }
    } catch (e) {
      debugPrint('Error saving owned Pokemon: $e');
    }
  }

  /// Saves unlocked Pokemon to home screen by adding it to SharedPreferences
  Future<void> _addPokemonToHomeScreen(Map<String, dynamic> pokemon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentsJson = prefs.getStringList('agents') ?? [];

      // Create a PokeAgent from the Pokemon data
      final newAgent = PokeAgent(
        id: pokemon['id'].toString(),
        name: pokemon['name'],
        type: (pokemon['types'] as List<String>).first,
        imageUrl: pokemon['imageUrl'],
        xp: (pokemon['level'] as int) * 100,
        evolutionStage: 1,
        personality: 'Brave',
        stats: {
          'hp': 100,
          'attack': 50 + (pokemon['level'] as int),
          'defense': 40 + (pokemon['level'] as int),
          'speed': 45 + (pokemon['level'] as int),
          'special': 50 + (pokemon['level'] as int),
        },
        isFavorite: true,
      );

      // Check if this Pokemon already exists
      final existingAgents =
          agentsJson
              .map((json) => PokeAgent.fromJson(jsonDecode(json)))
              .toList();

      final alreadyExists = existingAgents.any((a) => a.id == newAgent.id);

      if (!alreadyExists) {
        agentsJson.add(jsonEncode(newAgent.toJson()));
        await prefs.setStringList('agents', agentsJson);
      }
    } catch (e) {
      debugPrint('Error saving Pokemon to home screen: $e');
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
    final isOwned = pokemon['isOwned'] as bool? ?? true;

    if (!isOwned) {
      // Show purchase dialog for locked Pokemon
      _showPurchaseDialog(pokemon);
      return;
    }

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
                    _startBattle(pokemon);
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

  void _showPurchaseDialog(Map<String, dynamic> pokemon) {
    final backgroundColor = pokemon['backgroundColor'] as Color;
    final price = pokemon['price'] as double? ?? 0.0;
    final rarity = pokemon['rarity'] as String? ?? 'Common';
    final types = pokemon['types'] as List<String>;
    final level = pokemon['level'] as int;

    Color rarityColor;
    IconData rarityIcon;
    switch (rarity) {
      case 'Mythical':
        rarityColor = const Color(0xFFFF69B4);
        rarityIcon = Icons.auto_awesome;
        break;
      case 'Legendary':
        rarityColor = const Color(0xFFFFD700);
        rarityIcon = Icons.star;
        break;
      case 'Rare':
        rarityColor = const Color(0xFF9C27B0);
        rarityIcon = Icons.diamond;
        break;
      default:
        rarityColor = const Color(0xFF4CAF50);
        rarityIcon = Icons.circle;
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(20),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with Pokemon showcase
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                backgroundColor.withOpacity(0.9),
                                backgroundColor,
                                backgroundColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            children: [
                              // NFT Badge
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
                                          'NFT',
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

                              const SizedBox(height: 16),

                              // Pokemon Image with effects
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow effect
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Background circle
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Pokemon image
                                  CachedNetworkImage(
                                    imageUrl: pokemon['imageUrl'],
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.contain,
                                  ),
                                  // Lock badge
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.lock,
                                        color: backgroundColor,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Pokemon name
                              Text(
                                pokemon['name'],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Level and Rarity
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Lv. $level',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: rarityColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          rarityIcon,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rarity,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Type badges
                              Wrap(
                                spacing: 6,
                                children:
                                    types.map((type) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getTypeIcon(type),
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              type,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // Payment Section
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Price Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF667eea).withOpacity(0.1),
                                      const Color(0xFF764ba2).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF667eea,
                                    ).withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // NFT Price
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF627EEA,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Image.network(
                                                'https://cryptologos.cc/logos/ethereum-eth-logo.png',
                                                width: 20,
                                                height: 20,
                                                errorBuilder:
                                                    (_, __, ___) => const Text(
                                                      'Ξ',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF627EEA,
                                                        ),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Price',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${price.toStringAsFixed(3)} ETH',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: rarityColor.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            rarity,
                                            style: GoogleFonts.poppins(
                                              color: rarityColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Divider with "Your Wallet"
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'Your Wallet',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade400,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Balance
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Balance',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color:
                                                    _walletBalance >= price
                                                        ? const Color(
                                                          0xFF4CAF50,
                                                        )
                                                        : const Color(
                                                          0xFFE53935,
                                                        ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (_walletBalance >=
                                                                price
                                                            ? const Color(
                                                              0xFF4CAF50,
                                                            )
                                                            : const Color(
                                                              0xFFE53935,
                                                            ))
                                                        .withOpacity(0.4),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${_walletBalance.toStringAsFixed(3)} ETH',
                                              style: GoogleFonts.poppins(
                                                color:
                                                    _walletBalance >= price
                                                        ? const Color(
                                                          0xFF4CAF50,
                                                        )
                                                        : const Color(
                                                          0xFFE53935,
                                                        ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // After purchase balance
                                    if (_walletBalance >= price) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'After Purchase',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade400,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '${(_walletBalance - price).toStringAsFixed(3)} ETH',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade500,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Warning for insufficient balance
                              if (_walletBalance < price) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE53935,
                                    ).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE53935,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFE53935,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Color(0xFFE53935),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Insufficient Balance',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFFE53935),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'Need ${(price - _walletBalance).toStringAsFixed(3)} more ETH',
                                              style: GoogleFonts.poppins(
                                                color: const Color(
                                                  0xFFE53935,
                                                ).withOpacity(0.7),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Purchase Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      _isProcessingPayment ||
                                              _walletBalance < price
                                          ? null
                                          : () async {
                                            setDialogState(
                                              () => _isProcessingPayment = true,
                                            );

                                            await Future.delayed(
                                              const Duration(seconds: 2),
                                            );

                                            setState(() {
                                              _walletBalance -= price;
                                              final index = _samplePokemon
                                                  .indexWhere(
                                                    (p) =>
                                                        p['id'] ==
                                                        pokemon['id'],
                                                  );
                                              if (index != -1) {
                                                _samplePokemon[index]['isOwned'] =
                                                    true;
                                              }
                                              _isProcessingPayment = false;
                                            });

                                            await _saveOwnedPokemon(
                                              pokemon['id'].toString(),
                                            );
                                            await _addPokemonToHomeScreen(
                                              pokemon,
                                            );

                                            Navigator.pop(context);
                                            _showPurchaseSuccessDialog(pokemon);
                                          },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _walletBalance >= price
                                            ? backgroundColor
                                            : Colors.grey.shade300,
                                    foregroundColor: Colors.white,
                                    elevation: _walletBalance >= price ? 4 : 0,
                                    shadowColor: backgroundColor.withOpacity(
                                      0.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
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
                                              const SizedBox(width: 14),
                                              Text(
                                                'Processing Transaction...',
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
                                                _walletBalance >= price
                                                    ? Icons.lock_open_rounded
                                                    : Icons.lock,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                _walletBalance >= price
                                                    ? 'Unlock for ${price.toStringAsFixed(3)} ETH'
                                                    : 'Insufficient Balance',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Secure transaction note
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

  void _showPurchaseSuccessDialog(Map<String, dynamic> pokemon) {
    final backgroundColor = pokemon['backgroundColor'] as Color;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'NFT Unlocked!',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${pokemon['name']} is now yours!',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                // Pokemon image
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: pokemon['imageUrl'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                // Transaction hash
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.grey.shade500,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TX: 0x${pokemon['id'].hashCode.toRadixString(16).padLeft(8, '0')}...',
                        style: GoogleFonts.robotoMono(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Awesome!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPokemonInfo(Map<String, dynamic> pokemon) {
    final backgroundColor = pokemon['backgroundColor'] as Color;
    final types = pokemon['types'] as List<String>;
    final level = pokemon['level'] as int;

    // Generate random stats based on level
    final random = math.Random(pokemon['id'].hashCode);
    final hp = 50 + level + random.nextInt(50);
    final attack = 40 + (level * 0.8).toInt() + random.nextInt(30);
    final defense = 35 + (level * 0.6).toInt() + random.nextInt(25);
    final speed = 45 + (level * 0.7).toInt() + random.nextInt(35);
    final specialAtk = 40 + (level * 0.75).toInt() + random.nextInt(30);
    final specialDef = 35 + (level * 0.65).toInt() + random.nextInt(25);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor.withOpacity(0.9),
                    backgroundColor.withOpacity(0.7),
                    const Color(0xFF1A1A2E),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Pokemon Image
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background pattern
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.0,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Close button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Pokemon number
                        Positioned(
                          top: 16,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#${pokemon['id'].toString().padLeft(3, '0')}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // Pokemon Image - centered
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Hero(
                            tag: 'pokemon-detail-dialog-${pokemon['id']}',
                            child: Container(
                              height: 150,
                              child: CachedNetworkImage(
                                imageUrl: pokemon['imageUrl'],
                                fit: BoxFit.contain,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Icon(
                                      Icons.catching_pokemon,
                                      size: 80,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Pokemon Info Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        children: [
                          // Name and Level
                          Text(
                            pokemon['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFFD700),
                                  const Color(0xFFFFA500),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Level $level',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Type badges
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children:
                                types.map((type) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(type),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getTypeColor(
                                            type,
                                          ).withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getTypeIcon(type),
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          type,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // Stats Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'BASE STATS',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.7),
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStatBar(
                                  'HP',
                                  hp,
                                  200,
                                  const Color(0xFF4CAF50),
                                ),
                                _buildStatBar(
                                  'Attack',
                                  attack,
                                  150,
                                  const Color(0xFFFF5722),
                                ),
                                _buildStatBar(
                                  'Defense',
                                  defense,
                                  150,
                                  const Color(0xFF2196F3),
                                ),
                                _buildStatBar(
                                  'Sp. Atk',
                                  specialAtk,
                                  150,
                                  const Color(0xFF9C27B0),
                                ),
                                _buildStatBar(
                                  'Sp. Def',
                                  specialDef,
                                  150,
                                  const Color(0xFF00BCD4),
                                ),
                                _buildStatBar(
                                  'Speed',
                                  speed,
                                  150,
                                  const Color(0xFFFFEB3B),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _startBattle(pokemon);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B35),
                                          Color(0xFFFF4444),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFFF6B35,
                                          ).withOpacity(0.4),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.sports_kabaddi,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Battle',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showPokemonDetails(pokemon);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF7C4DFF),
                                          Color(0xFF536DFE),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF7C4DFF,
                                          ).withOpacity(0.4),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.fitness_center,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Train',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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

  Widget _buildStatBar(String label, int value, int maxValue, Color color) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              '$value',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
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

  void _startBattle(Map<String, dynamic> pokemon) {
    // Create player's PokeAgent
    final playerLevel = pokemon['level'] as int;
    final myAgent = PokeAgent(
      id: pokemon['id'],
      name: pokemon['name'],
      type: (pokemon['types'] as List<String>).first.toLowerCase(),
      imageUrl: pokemon['imageUrl'],
      xp: playerLevel * 100,
      evolutionStage: 1,
      personality: 'Brave',
      stats: {
        'hp': 100,
        'attack': 50 + playerLevel,
        'defense': 40 + playerLevel,
        'speed': 45 + playerLevel,
      },
    );

    // Generate a random opponent from the sample Pokemon
    final random = math.Random();
    final opponents =
        _samplePokemon.where((p) => p['id'] != pokemon['id']).toList();
    final opponentData = opponents[random.nextInt(opponents.length)];
    final opponentLevel = opponentData['level'] as int;

    final opponentAgent = BattleAgent(
      tokenId: opponentData['id'].hashCode.abs(),
      name: opponentData['name'],
      imageUrl: opponentData['imageUrl'],
      level: opponentLevel,
      elementType: (opponentData['types'] as List<String>).first.toLowerCase(),
      hp: 100,
      attack: 50 + opponentLevel,
      defense: 40 + opponentLevel,
      speed: 45 + opponentLevel,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Flutter3DBattleScreen(
              myAgent: myAgent,
              opponentAgent: opponentAgent,
              battleId: DateTime.now().millisecondsSinceEpoch,
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
                  _samplePokemon.isEmpty
                      ? _buildEmptyState()
                      : _buildFavoritesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
    final isOwned = pokemon['isOwned'] as bool? ?? true;
    final price = pokemon['price'] as double? ?? 0.0;
    final rarity = pokemon['rarity'] as String? ?? 'Common';

    Color rarityColor;
    switch (rarity) {
      case 'Mythical':
        rarityColor = const Color(0xFFFF69B4);
        break;
      case 'Legendary':
        rarityColor = const Color(0xFFFFD700);
        break;
      case 'Rare':
        rarityColor = const Color(0xFF9C27B0);
        break;
      default:
        rarityColor = const Color(0xFF4CAF50);
    }

    return Dismissible(
      key: Key(
        'dismissible-${pokemon['id']}-$index-${DateTime.now().millisecondsSinceEpoch}',
      ),
      direction: isOwned ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOwned ? Colors.grey.shade200 : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showPokemonOptions(pokemon),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildPokemonImage(pokemon, isOwned, backgroundColor),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildPokemonInfo(pokemon, types, isOwned),
                      ),
                      isOwned
                          ? _buildFavoriteIcon(backgroundColor)
                          : _buildLockIcon(price, rarityColor),
                    ],
                  ),
                ),
              ),
            ),
            // Lock/Rarity badge for non-owned
            if (!isOwned)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: rarityColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        rarity == 'Mythical'
                            ? Icons.auto_awesome
                            : rarity == 'Legendary'
                            ? Icons.star
                            : rarity == 'Rare'
                            ? Icons.diamond
                            : Icons.circle,
                        color: rarityColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rarity,
                        style: GoogleFonts.poppins(
                          color: rarityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
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

  Widget _buildLockIcon(double price, Color rarityColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock, color: Colors.grey.shade500, size: 20),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF3861FB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${price.toStringAsFixed(2)} ETH',
            style: GoogleFonts.poppins(
              color: const Color(0xFF3861FB),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonImage(
    Map<String, dynamic> pokemon,
    bool isOwned,
    Color backgroundColor,
  ) {
    return Hero(
      tag: 'pokemon-fav-card-${pokemon['id']}',
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color:
              isOwned
                  ? backgroundColor.withOpacity(0.15)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child:
                  isOwned
                      ? CachedNetworkImage(
                        imageUrl: pokemon['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        placeholder:
                            (context, url) => Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    backgroundColor.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.catching_pokemon,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                      )
                      : ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.33,
                          0.33,
                          0.33,
                          0,
                          0,
                          0.33,
                          0.33,
                          0.33,
                          0,
                          0,
                          0.33,
                          0.33,
                          0.33,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0.7,
                          0,
                        ]),
                        child: CachedNetworkImage(
                          imageUrl: pokemon['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          placeholder:
                              (context, url) => Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.catching_pokemon,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                        ),
                      ),
            ),
            // Small lock icon for locked Pokemon
            if (!isOwned)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey.shade500,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonInfo(
    Map<String, dynamic> pokemon,
    List<String> types,
    bool isOwned,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '#${pokemon['id'].toString().padLeft(3, '0')}',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          pokemon['name'],
          style: GoogleFonts.poppins(
            color: isOwned ? Colors.black : Colors.grey.shade600,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children:
              types.map((type) => _buildTypeBadge(type, isOwned)).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(String type, [bool isOwned = true]) {
    final typeColor = _getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOwned ? typeColor.withOpacity(0.15) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOwned ? typeColor.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(type),
            color: isOwned ? typeColor : Colors.grey.shade500,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: GoogleFonts.poppins(
              color: isOwned ? typeColor : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteIcon(Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.favorite, color: backgroundColor, size: 22),
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
