import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'account_screen.dart';

class RegionsScreen extends StatefulWidget {
  const RegionsScreen({super.key});

  @override
  State<RegionsScreen> createState() => _RegionsScreenState();
}

class _RegionsScreenState extends State<RegionsScreen> {
  int _currentIndex = 1; // Regions tab is active

  // Region data with background images and starter Pokemon
  final List<Map<String, dynamic>> regions = [
    {
      'name': 'Kanto',
      'generation': '1st Generation',
      'pokemonCount': 151,
      'color': const Color(0xFF6DAA4A),
      'description': 'The original region where it all began',
      'backgroundImage': 'assets/images/regions/kanto.png',
      'starters': [1, 4, 7], // Bulbasaur, Charmander, Squirtle
    },
    {
      'name': 'Johto',
      'generation': '2nd Generation',
      'pokemonCount': 100,
      'color': const Color(0xFF8B6DAA),
      'description': 'A land of tradition and history',
      'backgroundImage': 'assets/images/regions/johto.png',
      'starters': [152, 155, 158], // Chikorita, Cyndaquil, Totodile
    },
    {
      'name': 'Hoenn',
      'generation': '3rd Generation',
      'pokemonCount': 135,
      'color': const Color(0xFF4A90D9),
      'description': 'Islands surrounded by vast oceans',
      'backgroundImage': 'assets/images/regions/hoenn.png',
      'starters': [252, 255, 258], // Treecko, Torchic, Mudkip
    },
    {
      'name': 'Sinnoh',
      'generation': '4th Generation',
      'pokemonCount': 107,
      'color': const Color(0xFF5B7BA6),
      'description': 'A cold region with ancient myths',
      'backgroundImage': 'assets/images/regions/sinnoh.png',
      'starters': [387, 390, 393], // Turtwig, Chimchar, Piplup
    },
    {
      'name': 'Unova',
      'generation': '5th Generation',
      'pokemonCount': 156,
      'color': const Color(0xFF6B8E9F),
      'description': 'A modern metropolis region',
      'backgroundImage': 'assets/images/regions/unova.png',
      'starters': [495, 498, 501], // Snivy, Tepig, Oshawott
    },
    {
      'name': 'Kalos',
      'generation': '6th Generation',
      'pokemonCount': 72,
      'color': const Color(0xFF9B6B9E),
      'description': 'Where beauty and fashion thrive',
      'backgroundImage': 'assets/images/regions/kalos.png',
      'starters': [650, 653, 656], // Chespin, Fennekin, Froakie
    },
    {
      'name': 'Alola',
      'generation': '7th Generation',
      'pokemonCount': 88,
      'color': const Color(0xFFE8A54B),
      'description': 'Tropical paradise islands',
      'backgroundImage': 'assets/images/regions/alola.png',
      'starters': [722, 725, 728], // Rowlet, Litten, Popplio
    },
    {
      'name': 'Galar',
      'generation': '8th Generation',
      'pokemonCount': 89,
      'color': const Color(0xFF7B5DAA),
      'description': 'Industrial revolution meets Pokemon',
      'backgroundImage': 'assets/images/regions/galar.png',
      'starters': [810, 813, 816], // Grookey, Scorbunny, Sobble
    },
  ];

  // Get static sprite URL for starter Pokemon
  String _getSpriteUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [_buildHeader(), Expanded(child: _buildRegionsList())],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF303943),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Regions',
            style: GoogleFonts.poppins(
              color: const Color(0xFF303943),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 80),
          duration: const Duration(milliseconds: 400),
          child: _buildRegionCard(region, index),
        );
      },
    );
  }

  Widget _buildRegionCard(Map<String, dynamic> region, int index) {
    final starters = region['starters'] as List<int>;
    final color = region['color'] as Color;

    return GestureDetector(
      onTap: () => _navigateToExplore(region),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image - Full width landscape
              Positioned.fill(
                child: Image.asset(
                  region['backgroundImage'],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color, color.withOpacity(0.7)],
                          ),
                        ),
                      ),
                ),
              ),
              // Gradient overlay for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left side - Region info
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            region['name'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            region['generation'],
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side - Starter Pokemon sprites
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children:
                            starters.map((pokemonId) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: _getSpriteUrl(pokemonId),
                                      fit: BoxFit.contain,
                                      placeholder:
                                          (context, url) => const SizedBox(),
                                      errorWidget:
                                          (context, url, error) => Icon(
                                            Icons.catching_pokemon,
                                            color: color,
                                            size: 28,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToExplore(Map<String, dynamic> region) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExploreScreen(region: region)),
    );
    // Trigger a rebuild when returning to refresh any caught Pokemon
    if (mounted) setState(() {});
  }

  Widget _buildBottomNavBar() {
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
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            // Already on Regions
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFCD3131),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon, size: 24),
            label: 'Pokedex',
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
}
