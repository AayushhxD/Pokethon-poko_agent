import 'package:dio/dio.dart';
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
    final evolvedNames = {1: name, 2: "$name-X", 3: "Mega-$name"};

    return {
      'newName': evolvedNames[stage] ?? name,
      'newImageUrl': 'https://via.placeholder.com/300?text=Stage$stage',
      'description': '$name has evolved to stage $stage!',
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
