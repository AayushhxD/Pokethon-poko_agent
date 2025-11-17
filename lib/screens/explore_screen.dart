import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/pokemon_data.dart';

class ExploreScreen extends StatefulWidget {
  final Map<String, dynamic> region;

  const ExploreScreen({super.key, required this.region});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Pokemon available in each region based on generation
  final Map<String, List<String>> regionPokemon = {
    'Kanto': [
      'Bulbasaur',
      'Ivysaur',
      'Venusaur',
      'Charmander',
      'Charmeleon',
      'Charizard',
      'Squirtle',
      'Wartortle',
      'Blastoise',
      'Pikachu',
      'Raichu',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Snorlax',
      'Regice',
    ],
    'Johto': [
      'Typhlosion',
      'Feraligatr',
      'Meganium',
      'Pichu',
      'Ampharos',
      'Jolteon',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Snorlax',
      'Regice',
    ],
    'Hoenn': [
      'Blaziken',
      'Swampert',
      'Sceptile',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Salamence',
      'Torkoal',
      'Camerupt',
      'Snorlax',
      'Regice',
    ],
    'Sinnoh': [
      'Infernape',
      'Empoleon',
      'Torterra',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Salamence',
      'Torkoal',
      'Camerupt',
      'Snorlax',
      'Regice',
    ],
    'Unova': [
      'Serperior',
      'Emboar',
      'Samurott',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Salamence',
      'Torkoal',
      'Camerupt',
      'Snorlax',
      'Regice',
    ],
    'Kalos': [
      'Delphox',
      'Greninja',
      'Chesnaught',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Salamence',
      'Torkoal',
      'Camerupt',
      'Snorlax',
      'Regice',
    ],
    'Alola': [
      'Decidueye',
      'Primarina',
      'Incineroar',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Salamence',
      'Torkoal',
      'Camerupt',
      'Snorlax',
      'Regice',
    ],
    'Galar': [
      'Rillaboom',
      'Cinderace',
      'Inteleon',
      'Arcanine',
      'Rapidash',
      'Ninetales',
      'Gyarados',
      'Kingdra',
      'Milotic',
      'Electabuzz',
      'Magnezone',
      'Electivire',
      'Salamence',
      'Torkoal',
      'Camerupt',
      'Snorlax',
      'Regice',
    ],
  };

  late List<String> currentRegionPokemon;

  @override
  void initState() {
    super.initState();
    currentRegionPokemon = regionPokemon[widget.region['name']] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.region['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(color),
            Expanded(child: _buildPokemonGrid(color)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(Color color) {
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: color),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore ${widget.region['name']}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2E3A59),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  widget.region['generation'],
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              '${currentRegionPokemon.length} Pokémon',
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonGrid(Color color) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: currentRegionPokemon.length,
      itemBuilder: (context, index) {
        final pokemonName = currentRegionPokemon[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: _buildPokemonCard(pokemonName, color, index),
        );
      },
    );
  }

  Widget _buildPokemonCard(String pokemonName, Color color, int index) {
    final pokemonStats = PokemonData.pokemonStats[pokemonName];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPokemonDetails(pokemonName, color),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Pokemon Image
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: PokemonData.getPngUrl(pokemonName),
                      fit: BoxFit.contain,
                      placeholder:
                          (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Icon(
                            Icons.catching_pokemon,
                            color: color,
                            size: 40,
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Pokemon Name
                Text(
                  pokemonName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E3A59),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Type indicator (simplified)
                if (pokemonStats != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(pokemonName),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getPokemonType(pokemonName),
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String pokemonName) {
    // Simplified type detection based on Pokemon name
    if (pokemonName.contains('Char') ||
        pokemonName.contains('Blaze') ||
        pokemonName.contains('Arcan') ||
        pokemonName.contains('Rapid') ||
        pokemonName.contains('Ninet') ||
        pokemonName.contains('Typh') ||
        pokemonName.contains('Infern') ||
        pokemonName.contains('Torko') ||
        pokemonName.contains('Camer') ||
        pokemonName.contains('Salam') ||
        pokemonName.contains('Entei') ||
        pokemonName.contains('Ho-Oh')) {
      return Colors.red.shade600;
    } else if (pokemonName.contains('Blasto') ||
        pokemonName.contains('Swamp') ||
        pokemonName.contains('Gyar') ||
        pokemonName.contains('Feral') ||
        pokemonName.contains('Empol') ||
        pokemonName.contains('King') ||
        pokemonName.contains('Milotic') ||
        pokemonName.contains('Ludic') ||
        pokemonName.contains('Swalot') ||
        pokemonName.contains('Quag') ||
        pokemonName.contains('Pelip') ||
        pokemonName.contains('Craw') ||
        pokemonName.contains('Whisc') ||
        pokemonName.contains('Relic') ||
        pokemonName.contains('Huntail')) {
      return Colors.blue.shade600;
    } else if (pokemonName.contains('Pika') ||
        pokemonName.contains('Raich') ||
        pokemonName.contains('Elect') ||
        pokemonName.contains('Magn') ||
        pokemonName.contains('Amph') ||
        pokemonName.contains('Jolt') ||
        pokemonName.contains('Lux') ||
        pokemonName.contains('Zap')) {
      return Colors.yellow.shade600;
    } else if (pokemonName.contains('Bulb') ||
        pokemonName.contains('Ivys') ||
        pokemonName.contains('Venus') ||
        pokemonName.contains('Chikor') ||
        pokemonName.contains('Megan') ||
        pokemonName.contains('Treec') ||
        pokemonName.contains('Grov') ||
        pokemonName.contains('Scept') ||
        pokemonName.contains('Turtw') ||
        pokemonName.contains('Grotl') ||
        pokemonName.contains('Torter')) {
      return Colors.green.shade600;
    }
    return Colors.grey.shade600;
  }

  String _getPokemonType(String pokemonName) {
    if (pokemonName.contains('Char') ||
        pokemonName.contains('Blaze') ||
        pokemonName.contains('Arcan') ||
        pokemonName.contains('Rapid') ||
        pokemonName.contains('Ninet') ||
        pokemonName.contains('Typh') ||
        pokemonName.contains('Infern') ||
        pokemonName.contains('Torko') ||
        pokemonName.contains('Camer') ||
        pokemonName.contains('Salam') ||
        pokemonName.contains('Entei') ||
        pokemonName.contains('Ho-Oh')) {
      return 'Fire';
    } else if (pokemonName.contains('Blasto') ||
        pokemonName.contains('Swamp') ||
        pokemonName.contains('Gyar') ||
        pokemonName.contains('Feral') ||
        pokemonName.contains('Empol') ||
        pokemonName.contains('King') ||
        pokemonName.contains('Milotic') ||
        pokemonName.contains('Ludic') ||
        pokemonName.contains('Swalot') ||
        pokemonName.contains('Quag') ||
        pokemonName.contains('Pelip') ||
        pokemonName.contains('Craw') ||
        pokemonName.contains('Whisc') ||
        pokemonName.contains('Relic') ||
        pokemonName.contains('Huntail')) {
      return 'Water';
    } else if (pokemonName.contains('Pika') ||
        pokemonName.contains('Raich') ||
        pokemonName.contains('Elect') ||
        pokemonName.contains('Magn') ||
        pokemonName.contains('Amph') ||
        pokemonName.contains('Jolt') ||
        pokemonName.contains('Lux') ||
        pokemonName.contains('Zap')) {
      return 'Electric';
    } else if (pokemonName.contains('Bulb') ||
        pokemonName.contains('Ivys') ||
        pokemonName.contains('Venus') ||
        pokemonName.contains('Chikor') ||
        pokemonName.contains('Megan') ||
        pokemonName.contains('Treec') ||
        pokemonName.contains('Grov') ||
        pokemonName.contains('Scept') ||
        pokemonName.contains('Turtw') ||
        pokemonName.contains('Grotl') ||
        pokemonName.contains('Torter')) {
      return 'Grass';
    }
    return 'Normal';
  }

  void _showPokemonDetails(String pokemonName, Color color) {
    final pokemonStats = PokemonData.pokemonStats[pokemonName];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Pokemon Image
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: PokemonData.getPngUrl(pokemonName),
                            fit: BoxFit.contain,
                            placeholder:
                                (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Icon(
                                  Icons.catching_pokemon,
                                  color: color,
                                  size: 80,
                                ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Pokemon Name
                        Text(
                          pokemonName,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E3A59),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(pokemonName),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getPokemonType(pokemonName),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        if (pokemonStats != null) ...[
                          // Stats Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Base Stats',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E3A59),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStatRow(
                                  'HP',
                                  pokemonStats['hp'],
                                  Colors.red,
                                ),
                                _buildStatRow(
                                  'Attack',
                                  pokemonStats['attack'],
                                  Colors.orange,
                                ),
                                _buildStatRow(
                                  'Defense',
                                  pokemonStats['defense'],
                                  Colors.yellow.shade700,
                                ),
                                _buildStatRow(
                                  'Sp. Attack',
                                  pokemonStats['sp-attack'],
                                  Colors.blue,
                                ),
                                _buildStatRow(
                                  'Sp. Defense',
                                  pokemonStats['sp-defense'],
                                  Colors.green,
                                ),
                                _buildStatRow(
                                  'Speed',
                                  pokemonStats['speed'],
                                  Colors.purple,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Additional Info
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Height',
                                  '${pokemonStats['height']}m',
                                  Icons.height,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard(
                                  'Weight',
                                  '${pokemonStats['weight']}kg',
                                  Icons.monitor_weight,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Category',
                                  pokemonStats['category'],
                                  Icons.category,
                                  Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard(
                                  'Abilities',
                                  (pokemonStats['abilities'] as List).join(
                                    ', ',
                                  ),
                                  Icons.flash_on,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: BorderSide(color: color, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added $pokemonName to your collection!',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: color,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Catch',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
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
              ],
            ),
          ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3A59),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value / 255, // Max stat is 255
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E3A59),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return GestureDetector(
      onTap: () {}, // Prevent taps from bubbling up
      child: Container(
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
                _buildBottomNavItem(Icons.explore_outlined, 'Pokedex', () {
                  // Go back to home screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
                _buildBottomNavItem(Icons.location_on, 'Regions', () {
                  Navigator.of(context).pop(); // Go back to regions screen
                }),
                _buildBottomNavItem(Icons.favorite_border, 'Favorites', () {
                  // Go back to home screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
                _buildBottomNavItem(Icons.person_outline, 'Account', () {
                  // Go back to home screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
    );
  }
}
