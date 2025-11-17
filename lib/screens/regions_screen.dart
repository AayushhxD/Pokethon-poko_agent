import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/theme.dart';
import '../data/pokemon_data.dart';
import 'explore_screen.dart';

class RegionsScreen extends StatefulWidget {
  const RegionsScreen({super.key});

  @override
  State<RegionsScreen> createState() => _RegionsScreenState();
}

class _RegionsScreenState extends State<RegionsScreen> {
  final List<Map<String, dynamic>> regions = const [
    {
      'name': 'Kanto',
      'generation': '1st Generation',
      'color': Color(0xFF88A2D8),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png', // Bulbasaur
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png', // Charmander
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png', // Squirtle
      ],
    },
    {
      'name': 'Johto',
      'generation': '2nd Generation',
      'color': Color(0xFFD89090),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/152.png', // Chikorita
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/155.png', // Cyndaquil
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/158.png', // Totodile
      ],
    },
    {
      'name': 'Hoenn',
      'generation': '3rd Generation',
      'color': Color(0xFFA8D890),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/252.png', // Treecko
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/255.png', // Torchic
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/258.png', // Mudkip
      ],
    },
    {
      'name': 'Sinnoh',
      'generation': '4th Generation',
      'color': Color(0xFFF5C890),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/387.png', // Turtwig
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/390.png', // Chimchar
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/393.png', // Piplup
      ],
    },
    {
      'name': 'Unova',
      'generation': '5th Generation',
      'color': Color(0xFFB8A8D8),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/495.png', // Snivy
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/498.png', // Tepig
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/501.png', // Oshawott
      ],
    },
    {
      'name': 'Kalos',
      'generation': '6th Generation',
      'color': Color(0xFFE8A8C8),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/650.png', // Chespin
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/653.png', // Fennekin
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/656.png', // Froakie
      ],
    },
    {
      'name': 'Alola',
      'generation': '7th Generation',
      'color': Color(0xFFF8D090),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/722.png', // Rowlet
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/725.png', // Litten
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/728.png', // Popplio
      ],
    },
    {
      'name': 'Galar',
      'generation': '8th Generation',
      'color': Color(0xFFA8C8E8),
      'pokemonSprites': [
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/810.png', // Grookey
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/813.png', // Scorbunny
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/816.png', // Sobble
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [_buildHeader(), Expanded(child: _buildRegionsList())],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
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
        children: [
          Text(
            'Regions',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2E3A59),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: _buildRegionCard(region, index),
        );
      },
    );
  }

  Widget _buildRegionCard(Map<String, dynamic> region, int index) {
    final color = region['color'] as Color;
    final pokemonSprites = region['pokemonSprites'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showRegionDetails(region),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Left side - Region info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region['name'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region['generation'],
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side - Pokemon sprites
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      pokemonSprites.map((spriteUrl) {
                        return Container(
                          width: 64,
                          height: 64,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: spriteUrl,
                            fit: BoxFit.contain,
                            placeholder:
                                (context, url) => Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
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
                                  size: 32,
                                ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
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
              _buildBottomNavItem(Icons.location_on, 'Regions', true, () {}),
              _buildBottomNavItem(
                Icons.favorite_border,
                'Favorites',
                false,
                () => Navigator.pop(context),
              ),
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

  void _showRegionDetails(Map<String, dynamic> region) {
    final color = region['color'] as Color;
    final pokemonSprites = region['pokemonSprites'] as List<String>;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Region Header
                        Text(
                          region['name'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          region['generation'],
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Featured Pokemon Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Starter Pokémon',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children:
                                    pokemonSprites.map((spriteUrl) {
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: spriteUrl,
                                          fit: BoxFit.contain,
                                          placeholder:
                                              (context, url) => Center(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(color),
                                                  ),
                                                ),
                                              ),
                                          errorWidget:
                                              (context, url, error) => Icon(
                                                Icons.catching_pokemon,
                                                color: color,
                                                size: 40,
                                              ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About This Region',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'The ${region['name']} region is home to many unique Pokémon species. Explore this region to discover and catch them all!',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.catching_pokemon,
                                label: 'Pokémon',
                                value: '151+',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.location_city,
                                label: 'Cities',
                                value: '8',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Explore Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ExploreScreen(region: region),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Explore ${region['name']}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
