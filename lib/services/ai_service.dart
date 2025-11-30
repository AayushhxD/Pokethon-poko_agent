import 'package:dio/dio.dart';
import '../data/pokemon_data.dart';
import '../utils/constants.dart';

class AIService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseApiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Chat with PokéAgent
  Future<String> chat({
    required String agentId,
    required String agentName,
    required String agentType,
    required String message,
    required String personality,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.chatEndpoint,
        data: {
          'agentId': agentId,
          'agentName': agentName,
          'agentType': agentType,
          'message': message,
          'personality': personality,
        },
      );

      return response.data['response'] as String;
    } catch (e) {
      // Fallback for demo/testing
      return _generateFallbackResponse(agentName, agentType, message);
    }
  }

  // Simulate Battle
  Future<Map<String, dynamic>> battle({
    required String agent1Id,
    required String agent1Name,
    required String agent1Type,
    required Map<String, int> agent1Stats,
    required String agent2Id,
    required String agent2Name,
    required String agent2Type,
    required Map<String, int> agent2Stats,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.battleEndpoint,
        data: {
          'agent1': {
            'id': agent1Id,
            'name': agent1Name,
            'type': agent1Type,
            'stats': agent1Stats,
          },
          'agent2': {
            'id': agent2Id,
            'name': agent2Name,
            'type': agent2Type,
            'stats': agent2Stats,
          },
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Fallback for demo/testing
      return _generateFallbackBattle(
        agent1Name,
        agent1Type,
        agent1Stats,
        agent2Name,
        agent2Type,
        agent2Stats,
      );
    }
  }

  // Generate Evolution Data
  Future<Map<String, dynamic>> evolve({
    required String agentId,
    required String agentName,
    required String agentType,
    required int newStage,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.evolveEndpoint,
        data: {
          'agentId': agentId,
          'agentName': agentName,
          'agentType': agentType,
          'newStage': newStage,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Fallback for demo/testing
      return _generateFallbackEvolution(agentName, agentType, newStage);
    }
  }

  // Fallback Responses (for testing without backend)
  String _generateFallbackResponse(String name, String type, String message) {
    final responses = [
      "$name here! ⚡ Ready to train!",
      "*$type energy surges* Let's do this!",
      "Zap! Zap! I'm getting stronger!",
      "That's amazing, trainer! Keep it up!",
      "*excited $type noises* I can feel the power!",
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  Map<String, dynamic> _generateFallbackBattle(
    String agent1Name,
    String agent1Type,
    Map<String, int> stats1,
    String agent2Name,
    String agent2Type,
    Map<String, int> stats2,
  ) {
    // Simple calculation: winner is based on total stats
    int total1 = stats1.values.reduce((a, b) => a + b);
    int total2 = stats2.values.reduce((a, b) => a + b);

    String winner = total1 >= total2 ? agent1Name : agent2Name;

    return {
      'winner': winner,
      'narrative': [
        "$agent1Name ($agent1Type) vs $agent2Name ($agent2Type)!",
        "$agent1Name used Thunder Strike! ⚡",
        "$agent2Name countered with Water Blast! 💧",
        "The battle was intense!",
        "$winner emerged victorious! 🏆",
      ],
      'turns': 3,
    };
  }

  Map<String, dynamic> _generateFallbackEvolution(
    String name,
    String type,
    int stage,
  ) {
    // Check if the Pokemon actually has evolutions
    if (!PokemonData.pokemonEvolutions.containsKey(name)) {
      // This Pokemon doesn't have evolutions, return the same name and current image
      return {
        'newName': name,
        'newImageUrl': PokemonData.getPngUrl(name),
        'description': '$name is already at its final evolution stage!',
        'statBoost': {
          'hp': 0,
          'attack': 0,
          'defense': 0,
          'speed': 0,
          'special': 0,
        },
      };
    }

    final evolutions = PokemonData.pokemonEvolutions[name]!;
    if (stage > evolutions.length) {
      // Trying to evolve beyond available evolutions
      final finalEvolvedName = evolutions.last['name']!;
      return {
        'newName': finalEvolvedName,
        'newImageUrl': PokemonData.getPngUrl(finalEvolvedName),
        'description': '$name is already at its final evolution stage!',
        'statBoost': {
          'hp': 0,
          'attack': 0,
          'defense': 0,
          'speed': 0,
          'special': 0,
        },
      };
    }

    // Get the evolved name from the evolution chain
    final evolvedName = evolutions[stage - 1]['name']!;

    // Try to get the correct image URL from PokemonData
    String newImageUrl = PokemonData.getPngUrl(evolvedName);

    // Fallback to generic images if PokemonData doesn't have the evolved form
    if (newImageUrl.isEmpty) {
      final evolutionImages = [
        // Fire Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png', // Charizard
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/157.png', // Typhlosion
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/392.png', // Infernape
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/257.png', // Blaziken
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/59.png', // Arcanine
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/229.png', // Houndoom
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/373.png', // Salamence
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/244.png', // Entei
        // Water Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png', // Blastoise
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/160.png', // Feraligatr
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/395.png', // Empoleon
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/260.png', // Swampert
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/230.png', // Kingdra
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/350.png', // Milotic
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/272.png', // Ludicolo
        // Grass Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png', // Venusaur
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/154.png', // Meganium
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/389.png', // Torterra
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/254.png', // Sceptile
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/282.png', // Gardevoir
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/376.png', // Metagross
        // Electric Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/26.png', // Raichu
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/135.png', // Jolteon
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/181.png', // Ampharos
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/462.png', // Magnezone
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/466.png', // Electivire
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/145.png', // Zapdos
        // Psychic Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/65.png', // Alakazam
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/196.png', // Espeon
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/475.png', // Gallade
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png', // Mewtwo
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/151.png', // Mew
        // Ice Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/144.png', // Articuno
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/471.png', // Glaceon
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/473.png', // Mamoswine
        // Dragon Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/149.png', // Dragonite
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/384.png', // Rayquaza
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/445.png', // Garchomp
        // Dark Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/461.png', // Weavile
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/229.png', // Houndoom
        // Steel Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/376.png', // Metagross
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/462.png', // Magnezone
        // Flying Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/145.png', // Zapdos
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/144.png', // Articuno
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/250.png', // Ho-Oh
        // Ground Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/473.png', // Mamoswine
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/260.png', // Swampert
        // Rock Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/376.png', // Metagross
        // Fighting Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/68.png', // Machamp
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/257.png', // Blaziken
        // Poison Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/317.png', // Swalot
        // Bug Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/212.png', // Scizor
        // Ghost Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/94.png', // Gengar
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/478.png', // Froslass
        // Fairy Type Evolutions
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/282.png', // Gardevoir
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/700.png', // Sylveon
        // Legendary Pokemon
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png', // Mewtwo
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/151.png', // Mew
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/144.png', // Articuno
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/145.png', // Zapdos
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/146.png', // Moltres
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/243.png', // Raikou
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/244.png', // Entei
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/245.png', // Suicune
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/249.png', // Lugia
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/250.png', // Ho-Oh
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/377.png', // Regirock
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/378.png', // Regice
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/379.png', // Registeel
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/380.png', // Latias
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/381.png', // Latios
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/382.png', // Kyogre
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/383.png', // Groudon
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/384.png', // Rayquaza
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/385.png', // Jirachi
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/386.png', // Deoxys
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/480.png', // Uxie
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/481.png', // Mesprit
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/482.png', // Azelf
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/483.png', // Dialga
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/484.png', // Palkia
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/485.png', // Heatrot
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/486.png', // Regigigas
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/487.png', // Giratina
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/488.png', // Cresselia
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/489.png', // Phione
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/490.png', // Manaphy
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/491.png', // Darkrai
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/492.png', // Shaymin
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/493.png', // Arceus
      ];
      newImageUrl = evolutionImages[(stage - 1) % evolutionImages.length];
    }

    return {
      'newName': evolvedName,
      'newImageUrl': newImageUrl,
      'description': '$name has evolved to $evolvedName!',
      'statBoost': {
        'hp': 20,
        'attack': 15,
        'defense': 15,
        'speed': 10,
        'special': 20,
      },
    };
  }
}
