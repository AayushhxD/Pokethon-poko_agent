import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStatsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  int _ownedPokemonCount = 0;
  int _totalBattles = 0;
  int _totalWins = 0;
  int _totalLosses = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalXpEarned = 0;

  UserStatsService(this._prefs) {
    _loadStats();
  }

  // Getters
  int get ownedPokemonCount => _ownedPokemonCount;
  int get totalBattles => _totalBattles;
  int get totalWins => _totalWins;
  int get totalLosses => _totalLosses;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get totalXpEarned => _totalXpEarned;

  // Win rate percentage
  double get winRate {
    if (_totalBattles == 0) return 0.0;
    return (_totalWins / _totalBattles) * 100;
  }

  String get formattedWinRate {
    return '${winRate.toStringAsFixed(1)}%';
  }

  // Load stats from local storage
  Future<void> _loadStats() async {
    _ownedPokemonCount = _prefs.getInt('owned_pokemon_count') ?? 0;
    _totalBattles = _prefs.getInt('total_battles') ?? 0;
    _totalWins = _prefs.getInt('total_wins') ?? 0;
    _totalLosses = _prefs.getInt('total_losses') ?? 0;
    _currentStreak = _prefs.getInt('current_streak') ?? 0;
    _bestStreak = _prefs.getInt('best_streak') ?? 0;
    _totalXpEarned = _prefs.getInt('total_xp_earned') ?? 0;
    notifyListeners();
  }

  // Save all stats to local storage
  Future<void> _saveStats() async {
    await _prefs.setInt('owned_pokemon_count', _ownedPokemonCount);
    await _prefs.setInt('total_battles', _totalBattles);
    await _prefs.setInt('total_wins', _totalWins);
    await _prefs.setInt('total_losses', _totalLosses);
    await _prefs.setInt('current_streak', _currentStreak);
    await _prefs.setInt('best_streak', _bestStreak);
    await _prefs.setInt('total_xp_earned', _totalXpEarned);
    notifyListeners();
  }

  // Add a new Pokémon
  Future<void> addPokemon({int count = 1}) async {
    _ownedPokemonCount += count;
    await _saveStats();
    debugPrint('🎮 Pokémon count updated: $_ownedPokemonCount');
  }

  // Remove a Pokémon
  Future<void> removePokemon({int count = 1}) async {
    _ownedPokemonCount = (_ownedPokemonCount - count).clamp(
      0,
      _ownedPokemonCount,
    );
    await _saveStats();
  }

  // Set owned Pokémon count (from blockchain sync)
  Future<void> setOwnedPokemonCount(int count) async {
    _ownedPokemonCount = count;
    await _saveStats();
  }

  // Record a battle win
  Future<void> recordWin({int xpEarned = 10}) async {
    _totalBattles++;
    _totalWins++;
    _currentStreak++;
    _totalXpEarned += xpEarned;

    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }

    await _saveStats();
    debugPrint('🏆 Battle won! Wins: $_totalWins, Streak: $_currentStreak');
  }

  // Record a battle loss
  Future<void> recordLoss() async {
    _totalBattles++;
    _totalLosses++;
    _currentStreak = 0; // Reset streak on loss
    await _saveStats();
    debugPrint('💔 Battle lost! Losses: $_totalLosses');
  }

  // Add XP
  Future<void> addXp(int amount) async {
    _totalXpEarned += amount;
    await _saveStats();
  }

  // Reset all stats (for new user or logout)
  Future<void> resetStats() async {
    _ownedPokemonCount = 0;
    _totalBattles = 0;
    _totalWins = 0;
    _totalLosses = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _totalXpEarned = 0;

    await _prefs.remove('owned_pokemon_count');
    await _prefs.remove('total_battles');
    await _prefs.remove('total_wins');
    await _prefs.remove('total_losses');
    await _prefs.remove('current_streak');
    await _prefs.remove('best_streak');
    await _prefs.remove('total_xp_earned');

    notifyListeners();
    debugPrint('📊 Stats reset');
  }

  // Initialize with default mock data for new users (for demo)
  Future<void> initializeWithMockData() async {
    if (_totalBattles == 0 && _ownedPokemonCount == 0) {
      // Initialize with some starter data for demo
      _ownedPokemonCount = 3; // Starter Pokémon from battle_service mock
      _totalBattles = 0;
      _totalWins = 0;
      _totalLosses = 0;
      await _saveStats();
      debugPrint('📊 Initialized with starter Pokémon');
    }
  }
}
