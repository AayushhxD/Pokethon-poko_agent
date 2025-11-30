import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../data/pokemon_data.dart';
import '../services/wallet_service.dart';
import 'catch_pokemon_screen.dart';

class ExploreScreen extends StatefulWidget {
  final Map<String, dynamic> region;

  const ExploreScreen({super.key, required this.region});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  String _selectedType = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _types = [
    'All',
    'Fire',
    'Water',
    'Grass',
    'Electric',
    'Normal',
    'Ice',
    'Fighting',
    'Poison',
    'Ground',
    'Flying',
    'Psychic',
    'Bug',
    'Rock',
    'Ghost',
    'Dragon',
    'Dark',
    'Steel',
    'Fairy',
  ];

  // Pokemon type colors
  final Map<String, Color> typeColors = {
    'Fire': const Color(0xFFFB6C6C),
    'Water': const Color(0xFF77BDFE),
    'Grass': const Color(0xFF48D0B0),
    'Electric': const Color(0xFFFFCE4B),
    'Normal': const Color(0xFFA0A29F),
    'Ice': const Color(0xFF8ED8D8),
    'Fighting': const Color(0xFFD04164),
    'Poison': const Color(0xFFA864C7),
    'Ground': const Color(0xFFD97746),
    'Flying': const Color(0xFF93B2C7),
    'Psychic': const Color(0xFFF85888),
    'Bug': const Color(0xFF92BC2C),
    'Rock': const Color(0xFFC5B78C),
    'Ghost': const Color(0xFF5269AD),
    'Dragon': const Color(0xFF0B6DC3),
    'Dark': const Color(0xFF595761),
    'Steel': const Color(0xFF5695A3),
    'Fairy': const Color(0xFFEC8FE6),
  };

  // Pokemon available in each region based on generation
  final Map<String, List<Map<String, dynamic>>> regionPokemon = {
    'Kanto': [
      {
        'name': 'Bulbasaur',
        'id': 1,
        'types': ['Grass', 'Poison'],
      },
      {
        'name': 'Ivysaur',
        'id': 2,
        'types': ['Grass', 'Poison'],
      },
      {
        'name': 'Venusaur',
        'id': 3,
        'types': ['Grass', 'Poison'],
      },
      {
        'name': 'Charmander',
        'id': 4,
        'types': ['Fire'],
      },
      {
        'name': 'Charmeleon',
        'id': 5,
        'types': ['Fire'],
      },
      {
        'name': 'Charizard',
        'id': 6,
        'types': ['Fire', 'Flying'],
      },
      {
        'name': 'Squirtle',
        'id': 7,
        'types': ['Water'],
      },
      {
        'name': 'Wartortle',
        'id': 8,
        'types': ['Water'],
      },
      {
        'name': 'Blastoise',
        'id': 9,
        'types': ['Water'],
      },
      {
        'name': 'Pikachu',
        'id': 25,
        'types': ['Electric'],
      },
      {
        'name': 'Raichu',
        'id': 26,
        'types': ['Electric'],
      },
      {
        'name': 'Arcanine',
        'id': 59,
        'types': ['Fire'],
      },
      {
        'name': 'Gyarados',
        'id': 130,
        'types': ['Water', 'Flying'],
      },
      {
        'name': 'Snorlax',
        'id': 143,
        'types': ['Normal'],
      },
      {
        'name': 'Dragonite',
        'id': 149,
        'types': ['Dragon', 'Flying'],
      },
      {
        'name': 'Mewtwo',
        'id': 150,
        'types': ['Psychic'],
      },
    ],
    'Johto': [
      {
        'name': 'Chikorita',
        'id': 152,
        'types': ['Grass'],
      },
      {
        'name': 'Cyndaquil',
        'id': 155,
        'types': ['Fire'],
      },
      {
        'name': 'Typhlosion',
        'id': 157,
        'types': ['Fire'],
      },
      {
        'name': 'Totodile',
        'id': 158,
        'types': ['Water'],
      },
      {
        'name': 'Feraligatr',
        'id': 160,
        'types': ['Water'],
      },
      {
        'name': 'Ampharos',
        'id': 181,
        'types': ['Electric'],
      },
      {
        'name': 'Espeon',
        'id': 196,
        'types': ['Psychic'],
      },
      {
        'name': 'Umbreon',
        'id': 197,
        'types': ['Dark'],
      },
      {
        'name': 'Tyranitar',
        'id': 248,
        'types': ['Rock', 'Dark'],
      },
      {
        'name': 'Lugia',
        'id': 249,
        'types': ['Psychic', 'Flying'],
      },
      {
        'name': 'Ho-Oh',
        'id': 250,
        'types': ['Fire', 'Flying'],
      },
    ],
    'Hoenn': [
      {
        'name': 'Treecko',
        'id': 252,
        'types': ['Grass'],
      },
      {
        'name': 'Torchic',
        'id': 255,
        'types': ['Fire'],
      },
      {
        'name': 'Blaziken',
        'id': 257,
        'types': ['Fire', 'Fighting'],
      },
      {
        'name': 'Mudkip',
        'id': 258,
        'types': ['Water'],
      },
      {
        'name': 'Swampert',
        'id': 260,
        'types': ['Water', 'Ground'],
      },
      {
        'name': 'Gardevoir',
        'id': 282,
        'types': ['Psychic', 'Fairy'],
      },
      {
        'name': 'Salamence',
        'id': 373,
        'types': ['Dragon', 'Flying'],
      },
      {
        'name': 'Metagross',
        'id': 376,
        'types': ['Steel', 'Psychic'],
      },
      {
        'name': 'Rayquaza',
        'id': 384,
        'types': ['Dragon', 'Flying'],
      },
    ],
    'Sinnoh': [
      {
        'name': 'Turtwig',
        'id': 387,
        'types': ['Grass'],
      },
      {
        'name': 'Chimchar',
        'id': 390,
        'types': ['Fire'],
      },
      {
        'name': 'Infernape',
        'id': 392,
        'types': ['Fire', 'Fighting'],
      },
      {
        'name': 'Piplup',
        'id': 393,
        'types': ['Water'],
      },
      {
        'name': 'Empoleon',
        'id': 395,
        'types': ['Water', 'Steel'],
      },
      {
        'name': 'Lucario',
        'id': 448,
        'types': ['Fighting', 'Steel'],
      },
      {
        'name': 'Garchomp',
        'id': 445,
        'types': ['Dragon', 'Ground'],
      },
      {
        'name': 'Dialga',
        'id': 483,
        'types': ['Steel', 'Dragon'],
      },
      {
        'name': 'Palkia',
        'id': 484,
        'types': ['Water', 'Dragon'],
      },
      {
        'name': 'Giratina',
        'id': 487,
        'types': ['Ghost', 'Dragon'],
      },
    ],
    'Unova': [
      {
        'name': 'Snivy',
        'id': 495,
        'types': ['Grass'],
      },
      {
        'name': 'Tepig',
        'id': 498,
        'types': ['Fire'],
      },
      {
        'name': 'Emboar',
        'id': 500,
        'types': ['Fire', 'Fighting'],
      },
      {
        'name': 'Oshawott',
        'id': 501,
        'types': ['Water'],
      },
      {
        'name': 'Samurott',
        'id': 503,
        'types': ['Water'],
      },
      {
        'name': 'Zoroark',
        'id': 571,
        'types': ['Dark'],
      },
      {
        'name': 'Haxorus',
        'id': 612,
        'types': ['Dragon'],
      },
      {
        'name': 'Zekrom',
        'id': 644,
        'types': ['Dragon', 'Electric'],
      },
      {
        'name': 'Reshiram',
        'id': 643,
        'types': ['Dragon', 'Fire'],
      },
    ],
    'Kalos': [
      {
        'name': 'Chespin',
        'id': 650,
        'types': ['Grass'],
      },
      {
        'name': 'Fennekin',
        'id': 653,
        'types': ['Fire'],
      },
      {
        'name': 'Delphox',
        'id': 655,
        'types': ['Fire', 'Psychic'],
      },
      {
        'name': 'Froakie',
        'id': 656,
        'types': ['Water'],
      },
      {
        'name': 'Greninja',
        'id': 658,
        'types': ['Water', 'Dark'],
      },
      {
        'name': 'Aegislash',
        'id': 681,
        'types': ['Steel', 'Ghost'],
      },
      {
        'name': 'Sylveon',
        'id': 700,
        'types': ['Fairy'],
      },
      {
        'name': 'Xerneas',
        'id': 716,
        'types': ['Fairy'],
      },
      {
        'name': 'Yveltal',
        'id': 717,
        'types': ['Dark', 'Flying'],
      },
    ],
    'Alola': [
      {
        'name': 'Rowlet',
        'id': 722,
        'types': ['Grass', 'Flying'],
      },
      {
        'name': 'Decidueye',
        'id': 724,
        'types': ['Grass', 'Ghost'],
      },
      {
        'name': 'Litten',
        'id': 725,
        'types': ['Fire'],
      },
      {
        'name': 'Incineroar',
        'id': 727,
        'types': ['Fire', 'Dark'],
      },
      {
        'name': 'Popplio',
        'id': 728,
        'types': ['Water'],
      },
      {
        'name': 'Primarina',
        'id': 730,
        'types': ['Water', 'Fairy'],
      },
      {
        'name': 'Mimikyu',
        'id': 778,
        'types': ['Ghost', 'Fairy'],
      },
      {
        'name': 'Solgaleo',
        'id': 791,
        'types': ['Psychic', 'Steel'],
      },
      {
        'name': 'Lunala',
        'id': 792,
        'types': ['Psychic', 'Ghost'],
      },
    ],
    'Galar': [
      {
        'name': 'Grookey',
        'id': 810,
        'types': ['Grass'],
      },
      {
        'name': 'Rillaboom',
        'id': 812,
        'types': ['Grass'],
      },
      {
        'name': 'Scorbunny',
        'id': 813,
        'types': ['Fire'],
      },
      {
        'name': 'Cinderace',
        'id': 815,
        'types': ['Fire'],
      },
      {
        'name': 'Sobble',
        'id': 816,
        'types': ['Water'],
      },
      {
        'name': 'Inteleon',
        'id': 818,
        'types': ['Water'],
      },
      {
        'name': 'Corviknight',
        'id': 823,
        'types': ['Flying', 'Steel'],
      },
      {
        'name': 'Dragapult',
        'id': 887,
        'types': ['Dragon', 'Ghost'],
      },
      {
        'name': 'Zacian',
        'id': 888,
        'types': ['Fairy'],
      },
      {
        'name': 'Zamazenta',
        'id': 889,
        'types': ['Fighting'],
      },
    ],
    'Paldea': [
      {
        'name': 'Sprigatito',
        'id': 906,
        'types': ['Grass'],
      },
      {
        'name': 'Meowscarada',
        'id': 908,
        'types': ['Grass', 'Dark'],
      },
      {
        'name': 'Fuecoco',
        'id': 909,
        'types': ['Fire'],
      },
      {
        'name': 'Skeledirge',
        'id': 911,
        'types': ['Fire', 'Ghost'],
      },
      {
        'name': 'Quaxly',
        'id': 912,
        'types': ['Water'],
      },
      {
        'name': 'Quaquaval',
        'id': 914,
        'types': ['Water', 'Fighting'],
      },
      {
        'name': 'Koraidon',
        'id': 1007,
        'types': ['Fighting', 'Dragon'],
      },
      {
        'name': 'Miraidon',
        'id': 1008,
        'types': ['Electric', 'Dragon'],
      },
    ],
  };

  late List<Map<String, dynamic>> currentRegionPokemon;

  @override
  void initState() {
    super.initState();
    currentRegionPokemon = regionPokemon[widget.region['name']] ?? [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredPokemon {
    return currentRegionPokemon.where((pokemon) {
      final matchesSearch = pokemon['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesType =
          _selectedType == 'All' ||
          (pokemon['types'] as List).contains(_selectedType);
      return matchesSearch && matchesType;
    }).toList();
  }

  String _getPokemonImageUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.region['color'] as Color;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(color),
            _buildSearchBar(color),
            _buildTypeFilter(color),
            Expanded(child: _buildPokemonGrid(color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.region['name'],
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF303943),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.region['generation'],
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.catching_pokemon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  '${filteredPokemon.length}',
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF303943),
          ),
          decoration: InputDecoration(
            hintText: 'Search Pokémon...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade400),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter(Color color) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = type == _selectedType;
          final typeColor = typeColors[type] ?? color;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? (type == 'All' ? color : typeColor)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPokemonGrid(Color color) {
    final pokemon = filteredPokemon;

    if (pokemon.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Pokémon found',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: pokemon.length,
      itemBuilder: (context, index) {
        final poke = pokemon[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          duration: const Duration(milliseconds: 400),
          child: _buildPokemonCard(poke, color, index),
        );
      },
    );
  }

  Widget _buildPokemonCard(
    Map<String, dynamic> pokemon,
    Color regionColor,
    int index,
  ) {
    final types = pokemon['types'] as List;
    final primaryType = types.first as String;
    final color = typeColors[primaryType] ?? regionColor;
    final id = pokemon['id'] as int;
    final pokemonName = pokemon['name'] as String;
    final stats = PokemonData.pokemonStats[pokemonName];

    return GestureDetector(
      onTap: () => _showPokemonDetails(pokemon, color),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pokeball pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pokemon ID
                  Text(
                    '#${id.toString().padLeft(3, '0')}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Pokemon Name
                  Text(
                    pokemonName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Type badges
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        types
                            .map(
                              (type) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  type,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const Spacer(),
                  // Mini stats preview
                  if (stats != null)
                    Row(
                      children: [
                        _buildMiniStat('HP', stats['hp']),
                        const SizedBox(width: 6),
                        _buildMiniStat('ATK', stats['attack']),
                        const SizedBox(width: 6),
                        _buildMiniStat('SPD', stats['speed']),
                      ],
                    ),
                ],
              ),
            ),
            // Pokemon Image
            Positioned(
              right: 4,
              bottom: 4,
              child: Hero(
                tag: 'pokemon-explore-$id',
                child: CachedNetworkImage(
                  imageUrl: _getPokemonImageUrl(id),
                  height: 90,
                  width: 90,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(),
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.catching_pokemon,
                        color: Colors.white.withOpacity(0.5),
                        size: 60,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 7,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showPokemonDetails(Map<String, dynamic> pokemon, Color color) {
    final pokemonName = pokemon['name'] as String;
    final pokemonId = pokemon['id'] as int;
    final types = pokemon['types'] as List;
    final pokemonStats = PokemonData.pokemonStats[pokemonName];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
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
                        // Pokemon Image Container
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            children: [
                              // Background pattern
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Opacity(
                                  opacity: 0.1,
                                  child: Icon(
                                    Icons.catching_pokemon,
                                    size: 180,
                                    color: color,
                                  ),
                                ),
                              ),
                              // Pokemon Image
                              Center(
                                child: Hero(
                                  tag: 'pokemon-explore-$pokemonId',
                                  child: CachedNetworkImage(
                                    imageUrl: _getPokemonImageUrl(pokemonId),
                                    height: 160,
                                    fit: BoxFit.contain,
                                    placeholder:
                                        (context, url) => const SizedBox(),
                                    errorWidget:
                                        (context, url, error) => Icon(
                                          Icons.catching_pokemon,
                                          color: color.withOpacity(0.5),
                                          size: 100,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Pokemon ID
                        Text(
                          '#${pokemonId.toString().padLeft(3, '0')}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Pokemon Name
                        Text(
                          pokemonName,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF303943),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Type Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              types
                                  .map(
                                    (type) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: typeColors[type] ?? color,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        type,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),

                        const SizedBox(height: 32),

                        if (pokemonStats != null) ...[
                          // Stats Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Base Stats',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF303943),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildStatRow('HP', pokemonStats['hp'], color),
                                _buildStatRow(
                                  'Attack',
                                  pokemonStats['attack'],
                                  color,
                                ),
                                _buildStatRow(
                                  'Defense',
                                  pokemonStats['defense'],
                                  color,
                                ),
                                _buildStatRow(
                                  'Sp. Atk',
                                  pokemonStats['sp-attack'],
                                  color,
                                ),
                                _buildStatRow(
                                  'Sp. Def',
                                  pokemonStats['sp-defense'],
                                  color,
                                ),
                                _buildStatRow(
                                  'Speed',
                                  pokemonStats['speed'],
                                  color,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Info Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Height',
                                  '${pokemonStats['height']}m',
                                  Icons.straighten,
                                  color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  'Weight',
                                  '${pokemonStats['weight']}kg',
                                  Icons.fitness_center,
                                  color,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Category',
                                  pokemonStats['category'] ?? 'Unknown',
                                  Icons.category,
                                  color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  'Abilities',
                                  (pokemonStats['abilities'] as List?)?.first ??
                                      'Unknown',
                                  Icons.auto_awesome,
                                  color,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Default stats view when no data
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Stats coming soon!',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
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
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final walletService =
                                      Provider.of<WalletService>(
                                        context,
                                        listen: false,
                                      );

                                  // Check if user has enough balance
                                  if (!walletService.hasEnoughBalance(
                                    WalletService.catchCost,
                                  )) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Text(
                                              '🪙',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'Insufficient balance! Need ${WalletService.catchCost.toInt()} POKO to catch',
                                                style: GoogleFonts.poppins(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // Deduct catch cost
                                  await walletService.deductTokens(
                                    WalletService.catchCost,
                                  );

                                  Navigator.pop(context);
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CatchPokemonScreen(
                                            pokemon: pokemon,
                                            color: color,
                                          ),
                                    ),
                                  );
                                  if (result == true && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.catching_pokemon,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$pokemonName added to your collection!',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '-${WalletService.catchCost.toInt()} POKO',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white70,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: color,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.catching_pokemon,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Catch',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF303943),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / 255).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(4),
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF303943),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
