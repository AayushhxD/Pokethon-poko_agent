import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class LeaderboardEntry {
  final String odRank;
  final String odUsername;
  final String odAvatar;
  final int odWins;
  final int odBattles;
  final int odPokemonOwned;
  final int odTotalXp;
  final int odWinStreak;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.odRank,
    required this.odUsername,
    required this.odAvatar,
    required this.odWins,
    required this.odBattles,
    required this.odPokemonOwned,
    required this.odTotalXp,
    required this.odWinStreak,
    this.isCurrentUser = false,
  });

  double get winRate => odBattles > 0 ? (odWins / odBattles) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'rank': odRank,
    'username': odUsername,
    'avatar': odAvatar,
    'wins': odWins,
    'battles': odBattles,
    'pokemonOwned': odPokemonOwned,
    'totalXp': odTotalXp,
    'winStreak': odWinStreak,
    'isCurrentUser': isCurrentUser,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        odRank: json['rank'].toString(),
        odUsername: json['username'],
        odAvatar: json['avatar'],
        odWins: json['wins'],
        odBattles: json['battles'],
        odPokemonOwned: json['pokemonOwned'],
        odTotalXp: json['totalXp'],
        odWinStreak: json['winStreak'],
        isCurrentUser: json['isCurrentUser'] ?? false,
      );
}

enum LeaderboardType { wins, winStreak, pokemon, xp }

class LeaderboardService extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<LeaderboardEntry> _leaderboard = [];
  LeaderboardType _currentType = LeaderboardType.wins;
  bool _isLoading = false;

  LeaderboardService() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _generateMockLeaderboard();
  }

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  LeaderboardType get currentType => _currentType;
  bool get isLoading => _isLoading;

  // Mock usernames for demo
  final List<String> _mockUsernames = [
    'AshKetchum',
    'MistyWater',
    'BrockRock',
    'GaryOak',
    'RedChampion',
    'BlueRival',
    'CynthiaChamp',
    'LeonMaster',
    'StevenStone',
    'LancedragonM',
    'IrisChamp',
    'DianthaStar',
    'AlolaProf',
    'GalarHero',
    'KantoKing',
    'JohtoQueen',
    'HoennAce',
    'SinnohStar',
    'UnovaChamp',
    'KalosKnight',
  ];

  final List<String> _avatars = [
    '🔥',
    '💧',
    '⚡',
    '🌿',
    '❄️',
    '🧠',
    '🐉',
    '👻',
    '⭐',
    '🎯',
  ];

  void _generateMockLeaderboard() {
    _isLoading = true;
    notifyListeners();

    final random = math.Random();
    final entries = <LeaderboardEntry>[];

    // Get current user stats
    final userWins = _prefs?.getInt('total_wins') ?? 0;
    final userBattles = _prefs?.getInt('total_battles') ?? 0;
    final userPokemon = _prefs?.getInt('owned_pokemon_count') ?? 0;
    final userXp = _prefs?.getInt('total_xp_earned') ?? 0;
    final userStreak = _prefs?.getInt('best_streak') ?? 0;

    // Generate mock entries
    for (int i = 0; i < 20; i++) {
      final baseWins = (20 - i) * 5 + random.nextInt(20);
      final battles = baseWins + random.nextInt(baseWins ~/ 2 + 1);

      entries.add(
        LeaderboardEntry(
          odRank: '${i + 1}',
          odUsername: _mockUsernames[i],
          odAvatar: _avatars[random.nextInt(_avatars.length)],
          odWins: baseWins,
          odBattles: battles,
          odPokemonOwned: 10 + random.nextInt(50),
          odTotalXp: baseWins * 50 + random.nextInt(1000),
          odWinStreak: random.nextInt(15) + 1,
          isCurrentUser: false,
        ),
      );
    }

    // Add current user
    entries.add(
      LeaderboardEntry(
        odRank: 'You',
        odUsername: 'You',
        odAvatar: '🎮',
        odWins: userWins,
        odBattles: userBattles,
        odPokemonOwned: userPokemon,
        odTotalXp: userXp,
        odWinStreak: userStreak,
        isCurrentUser: true,
      ),
    );

    // Sort based on current type
    _sortLeaderboard(entries);

    _leaderboard = entries;
    _isLoading = false;
    notifyListeners();
  }

  void _sortLeaderboard(List<LeaderboardEntry> entries) {
    switch (_currentType) {
      case LeaderboardType.wins:
        entries.sort((a, b) => b.odWins.compareTo(a.odWins));
        break;
      case LeaderboardType.winStreak:
        entries.sort((a, b) => b.odWinStreak.compareTo(a.odWinStreak));
        break;
      case LeaderboardType.pokemon:
        entries.sort((a, b) => b.odPokemonOwned.compareTo(a.odPokemonOwned));
        break;
      case LeaderboardType.xp:
        entries.sort((a, b) => b.odTotalXp.compareTo(a.odTotalXp));
        break;
    }

    // Update ranks
    for (int i = 0; i < entries.length; i++) {
      if (!entries[i].isCurrentUser) {
        entries[i] = LeaderboardEntry(
          odRank: '${i + 1}',
          odUsername: entries[i].odUsername,
          odAvatar: entries[i].odAvatar,
          odWins: entries[i].odWins,
          odBattles: entries[i].odBattles,
          odPokemonOwned: entries[i].odPokemonOwned,
          odTotalXp: entries[i].odTotalXp,
          odWinStreak: entries[i].odWinStreak,
          isCurrentUser: false,
        );
      } else {
        entries[i] = LeaderboardEntry(
          odRank: '#${i + 1}',
          odUsername: 'You',
          odAvatar: entries[i].odAvatar,
          odWins: entries[i].odWins,
          odBattles: entries[i].odBattles,
          odPokemonOwned: entries[i].odPokemonOwned,
          odTotalXp: entries[i].odTotalXp,
          odWinStreak: entries[i].odWinStreak,
          isCurrentUser: true,
        );
      }
    }
  }

  void changeType(LeaderboardType type) {
    if (_currentType == type) return;
    _currentType = type;
    _sortLeaderboard(_leaderboard);
    notifyListeners();
  }

  Future<void> refresh() async {
    _generateMockLeaderboard();
  }

  int getCurrentUserRank() {
    final index = _leaderboard.indexWhere((e) => e.isCurrentUser);
    return index + 1;
  }
}
