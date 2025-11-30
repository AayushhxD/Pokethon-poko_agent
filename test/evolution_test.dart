import 'package:flutter_test/flutter_test.dart';
import 'package:poko_agent/data/pokemon_data.dart';
import 'package:poko_agent/services/ai_service.dart';

void main() {
  group('Evolution System Tests', () {
    test('Pikachu evolves to Raichu', () {
      // Test that Pikachu evolution returns Raichu
      final evolutions = PokemonData.pokemonEvolutions['Pikachu'];
      expect(evolutions, isNotNull);
      expect(evolutions!.length, greaterThanOrEqualTo(1));
      expect(evolutions[0]['name'], equals('Raichu'));
    });

    test('Torchic evolves to Combusken and Blaziken', () {
      // Test Torchic evolution chain
      final evolutions = PokemonData.pokemonEvolutions['Torchic'];
      expect(evolutions, isNotNull);
      expect(evolutions!.length, equals(2));
      expect(evolutions[0]['name'], equals('Combusken'));
      expect(evolutions[1]['name'], equals('Blaziken'));
    });

    test('Mudkip evolves to Marshtomp and Swampert', () {
      // Test Mudkip evolution chain
      final evolutions = PokemonData.pokemonEvolutions['Mudkip'];
      expect(evolutions, isNotNull);
      expect(evolutions!.length, equals(2));
      expect(evolutions[0]['name'], equals('Marshtomp'));
      expect(evolutions[1]['name'], equals('Swampert'));
    });

    test('Pokemon IDs are mapped correctly', () {
      // Test that evolved Pokemon have correct IDs
      expect(PokemonData.pokemonIds['Raichu'], equals(26));
      expect(PokemonData.pokemonIds['Combusken'], equals(256));
      expect(PokemonData.pokemonIds['Blaziken'], equals(257));
      expect(PokemonData.pokemonIds['Marshtomp'], equals(259));
      expect(PokemonData.pokemonIds['Swampert'], equals(260));
    });

    test('AI Service generates correct evolution names', () async {
      final aiService = AIService();

      // Test Pikachu evolution
      final pikachuResult = await aiService.evolve(
        agentId: 'test-id',
        agentName: 'Pikachu',
        agentType: 'Electric',
        newStage: 1,
      );
      expect(pikachuResult['newName'], equals('Raichu'));

      // Test Torchic evolution to stage 1
      final torchicResult1 = await aiService.evolve(
        agentId: 'test-id',
        agentName: 'Torchic',
        agentType: 'Fire',
        newStage: 1,
      );
      expect(torchicResult1['newName'], equals('Combusken'));

      // Test Torchic evolution to stage 2
      final torchicResult2 = await aiService.evolve(
        agentId: 'test-id',
        agentName: 'Torchic',
        agentType: 'Fire',
        newStage: 2,
      );
      expect(torchicResult2['newName'], equals('Blaziken'));
    });
  });
}
