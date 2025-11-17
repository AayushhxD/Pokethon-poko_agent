import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokeagent.dart';
import '../utils/theme.dart';
import 'nft_creature_details_screen.dart';

class NftInventoryScreen extends StatefulWidget {
  const NftInventoryScreen({super.key});

  @override
  State<NftInventoryScreen> createState() => _NftInventoryScreenState();
}

class _NftInventoryScreenState extends State<NftInventoryScreen> {
  final List<Map<String, dynamic>> _creatures = [
    {
      'id': '1',
      'name': 'Charizard',
      'type': 'Fire',
      'rarity': 'Legendary',
      'level': 85,
      'power': 2500,
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png',
      'backgroundColor': const Color(0xFFFFB366),
      'generation': 1,
      'skills': ['Fire Blast', 'Dragon Rage', 'Seismic Toss'],
    },
    {
      'id': '2',
      'name': 'Blastoise',
      'type': 'Water',
      'rarity': 'Legendary',
      'level': 82,
      'power': 2450,
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png',
      'backgroundColor': const Color(0xFF6BB8FF),
      'generation': 1,
      'skills': ['Hydro Pump', 'Ice Beam', 'Rapid Spin'],
    },
    {
      'id': '3',
      'name': 'Venusaur',
      'type': 'Grass',
      'rarity': 'Legendary',
      'level': 80,
      'power': 2400,
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png',
      'backgroundColor': const Color(0xFF90C878),
      'generation': 1,
      'skills': ['Solar Beam', 'Razor Leaf', 'Vine Whip'],
    },
    {
      'id': '4',
      'name': 'Pikachu',
      'type': 'Electric',
      'rarity': 'Rare',
      'level': 45,
      'power': 1200,
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
      'backgroundColor': const Color(0xFFFFE066),
      'generation': 1,
      'skills': ['Thunderbolt', 'Quick Attack', 'Thunder Wave'],
    },
    {
      'id': '5',
      'name': 'Dragonite',
      'type': 'Dragon',
      'rarity': 'Epic',
      'level': 78,
      'power': 2200,
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/149.png',
      'backgroundColor': const Color(0xFF8B5CF6),
      'generation': 1,
      'skills': ['Dragon Rush', 'Hyper Beam', 'Thunder Punch'],
    },
    {
      'id': '6',
      'name': 'Mewtwo',
      'type': 'Psychic',
      'rarity': 'Mythical',
      'level': 95,
      'power': 3000,
      'imageUrl':
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png',
      'backgroundColor': const Color(0xFFFF9AB8),
      'generation': 1,
      'skills': ['Psychic', 'Shadow Ball', 'Aura Sphere'],
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Fire',
    'Water',
    'Grass',
    'Electric',
    'Dragon',
    'Psychic',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilters(),
              Expanded(child: _buildCreatureGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'NFT Inventory',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_creatures.length} Creatures',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return FadeInLeft(
            delay: Duration(milliseconds: index * 100),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.white.withOpacity(0.1),
                selectedColor: Colors.blue.withOpacity(0.3),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected
                            ? Colors.blue
                            : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatureGrid() {
    final filteredCreatures =
        _selectedFilter == 'All'
            ? _creatures
            : _creatures
                .where((creature) => creature['type'] == _selectedFilter)
                .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredCreatures.length,
      itemBuilder: (context, index) {
        final creature = filteredCreatures[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: _buildCreatureCard(creature),
        );
      },
    );
  }

  Widget _buildCreatureCard(Map<String, dynamic> creature) {
    final rarityColor = _getRarityColor(creature['rarity']);

    return InkWell(
      onTap: () => _showCreatureDetails(creature),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              creature['backgroundColor'].withOpacity(0.3),
              creature['backgroundColor'].withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rarityColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: creature['backgroundColor'].withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Rarity badge
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rarityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  creature['rarity'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Creature image
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.catching_pokemon,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            // Creature info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    creature['name'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getTypeColor(
                        creature['type'],
                      ).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${creature['type']} • Lv.${creature['level']}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: Colors.yellow,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${creature['power']}',
                        style: GoogleFonts.poppins(
                          color: Colors.yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Common':
        return Colors.grey;
      case 'Rare':
        return Colors.blue;
      case 'Epic':
        return Colors.purple;
      case 'Legendary':
        return Colors.orange;
      case 'Mythical':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _showCreatureDetails(Map<String, dynamic> creature) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NftCreatureDetailsScreen(creature: creature),
      ),
    );
  }
}
