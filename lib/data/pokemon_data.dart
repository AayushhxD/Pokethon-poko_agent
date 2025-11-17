// Pokemon data with GIF URLs and stats
class PokemonData {
  // Map of Pokemon names to their PokeAPI IDs
  static const Map<String, int> pokemonIds = {
    // Fire Type
    'Charizard': 6,
    'Blaziken': 257,
    'Arcanine': 59,
    'Typhlosion': 157,
    'Infernape': 392,
    'Flareon': 136,
    'Rapidash': 78,
    'Ninetales': 38,
    'Magmar': 126,
    'Houndoom': 229,
    'Torkoal': 324,
    'Camerupt': 323,
    'Salamence': 373,
    'Entei': 244,
    'Ho-Oh': 250,

    // Water Type
    'Blastoise': 9,
    'Swampert': 260,
    'Gyarados': 130,
    'Feraligatr': 160,
    'Empoleon': 395,
    'Kingdra': 230,
    'Milotic': 350,
    'Ludicolo': 272,
    'Swalot': 317,
    'Quagsire': 195,
    'Pelipper': 279,
    'Crawdaunt': 342,
    'Whiscash': 340,
    'Relicanth': 369,
    'Huntail': 367,

    // Electric Type
    'Pikachu': 25,
    'Raichu': 26,
    'Electivire': 466,
    'Magnezone': 462,
    'Electabuzz': 125,
    'Zapdos': 145,
    'Manectric': 310,
    'Electrode': 101,
    'Ampharos': 181,
    'Jolteon': 135,
    'Luxray': 405,
    'Rotom': 479,
    'Elekid': 239,
    'Mareep': 179,
    'Pichu': 172,

    // Psychic Type
    'Mewtwo': 150,
    'Gardevoir': 282,
    'Gallade': 475,
    'Metagross': 376,
    'Alakazam': 65,
    'Espeon': 196,
    'Mew': 151,
    'Celebi': 251,
    'Jirachi': 385,
    'Deoxys': 386,
    'Bronzor': 436,
    'Chimecho': 358,
    'Wobbuffet': 202,
    'Slowking': 199,
    'Xatu': 178,

    // Grass Type
    'Venusaur': 3,
    'Sceptile': 254,
    'Torterra': 389,
    'Turtwig': 387,
    'Snivy': 495,
    'Leafeon': 470,
    'Chikorita': 152,
    'Meganium': 154,
    'Treecko': 252,
    'Grovyle': 253,
    'Tropius': 357,
    'Carnivine': 455,
    'Budew': 406,
    'Roserade': 407,
    'Tangela': 114,

    // Ice Type
    'Articuno': 144,
    'Glalie': 362,
    'Weavile': 461,
    'Glaceon': 471,
    'Lapras': 131,
    'Mamoswine': 473,
    'Froslass': 478,
    'Sneasel': 215,
    'Snorunt': 361,
    'Spheal': 363,
    'Sealeo': 364,
    'Walrein': 365,
    'Regice': 378,
    'Snorlax': 143,

    // Evolution forms
    'Bulbasaur': 1,
    'Ivysaur': 2,
    'Charmander': 4,
    'Charmeleon': 5,
    'Squirtle': 7,
    'Wartortle': 8,
  };

  // Get GIF URL for a Pokemon
  static String getGifUrl(String pokemonName) {
    final id = pokemonIds[pokemonName];
    if (id != null) {
      return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/$id.gif';
    }
    return '';
  }

  // Get PNG URL for a Pokemon
  static String getPngUrl(String pokemonName) {
    final id = pokemonIds[pokemonName];
    if (id != null) {
      return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    }
    return '';
  }

  // Pokemon stats data
  static const Map<String, Map<String, dynamic>> pokemonStats = {
    'Charizard': {
      'hp': 78,
      'attack': 84,
      'defense': 78,
      'sp-attack': 109,
      'sp-defense': 85,
      'speed': 100,
      'height': 1.7,
      'weight': 90.5,
      'category': 'Flame',
      'abilities': ['Blaze', 'Solar Power'],
      'gender': {'male': 87.5, 'female': 12.5},
    },
    'Blastoise': {
      'hp': 79,
      'attack': 83,
      'defense': 100,
      'sp-attack': 85,
      'sp-defense': 105,
      'speed': 78,
      'height': 1.6,
      'weight': 85.5,
      'category': 'Shellfish',
      'abilities': ['Torrent', 'Rain Dish'],
      'gender': {'male': 87.5, 'female': 12.5},
    },
    'Venusaur': {
      'hp': 80,
      'attack': 82,
      'defense': 83,
      'sp-attack': 100,
      'sp-defense': 100,
      'speed': 80,
      'height': 2.0,
      'weight': 100.0,
      'category': 'Seed',
      'abilities': ['Overgrow', 'Chlorophyll'],
      'gender': {'male': 87.5, 'female': 12.5},
    },
    'Pikachu': {
      'hp': 35,
      'attack': 55,
      'defense': 40,
      'sp-attack': 50,
      'sp-defense': 50,
      'speed': 90,
      'height': 0.4,
      'weight': 6.0,
      'category': 'Mouse',
      'abilities': ['Static', 'Lightning Rod'],
      'gender': {'male': 50.0, 'female': 50.0},
    },
    // Add more stats as needed
  };

  // Pokemon evolution chains
  static const Map<String, List<Map<String, String>>> pokemonEvolutions = {
    'Charizard': [
      {'name': 'Charmander', 'level': 'Base'},
      {'name': 'Charmeleon', 'level': 'Lv. 16'},
      {'name': 'Charizard', 'level': 'Lv. 36'},
    ],
    'Blastoise': [
      {'name': 'Squirtle', 'level': 'Base'},
      {'name': 'Wartortle', 'level': 'Lv. 16'},
      {'name': 'Blastoise', 'level': 'Lv. 36'},
    ],
    'Venusaur': [
      {'name': 'Bulbasaur', 'level': 'Base'},
      {'name': 'Ivysaur', 'level': 'Lv. 16'},
      {'name': 'Venusaur', 'level': 'Lv. 32'},
    ],
    'Pikachu': [
      {'name': 'Pichu', 'level': 'Baby'},
      {'name': 'Pikachu', 'level': 'Friendship'},
      {'name': 'Raichu', 'level': 'Thunder Stone'},
    ],
    // Add more evolutions as needed
  };
}
