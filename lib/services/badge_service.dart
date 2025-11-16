import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon; // Emoji icon
  final String rarity; // common, rare, epic, legendary
  final DateTime unlockedAt;
  final int xpReward;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    DateTime? unlockedAt,
    this.xpReward = 50,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'rarity': rarity,
      'unlockedAt': unlockedAt.toIso8601String(),
      'xpReward': xpReward,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      rarity: json['rarity'],
      unlockedAt: DateTime.parse(json['unlockedAt']),
      xpReward: json['xpReward'] ?? 50,
    );
  }
}

class BadgeService {
  static const String _storageKey = 'user_badges';

  // Available badges
  static final Map<String, Badge> availableBadges = {
    'first_agent': Badge(
      id: 'first_agent',
      name: 'First Steps',
      description: 'Minted your first PokéAgent',
      icon: '🎉',
      rarity: 'common',
      xpReward: 50,
    ),
    'first_chat': Badge(
      id: 'first_chat',
      name: 'Chatty Trainer',
      description: 'Had your first conversation',
      icon: '💬',
      rarity: 'common',
      xpReward: 50,
    ),
    'first_battle': Badge(
      id: 'first_battle',
      name: 'Battle Rookie',
      description: 'Won your first battle',
      icon: '⚔️',
      rarity: 'common',
      xpReward: 100,
    ),
    'first_evolution': Badge(
      id: 'first_evolution',
      name: 'Evolution Master',
      description: 'Evolved your first PokéAgent',
      icon: '✨',
      rarity: 'rare',
      xpReward: 200,
    ),
    'chat_master': Badge(
      id: 'chat_master',
      name: 'Conversation Expert',
      description: 'Had 100 conversations',
      icon: '🗣️',
      rarity: 'epic',
      xpReward: 500,
    ),
    'battle_champion': Badge(
      id: 'battle_champion',
      name: 'Battle Champion',
      description: 'Won 50 battles',
      icon: '🏆',
      rarity: 'epic',
      xpReward: 500,
    ),
    'type_collector': Badge(
      id: 'type_collector',
      name: 'Type Collector',
      description: 'Collected all 6 agent types',
      icon: '🎯',
      rarity: 'legendary',
      xpReward: 1000,
    ),
    'max_evolution': Badge(
      id: 'max_evolution',
      name: 'Ultimate Form',
      description: 'Reached max evolution stage',
      icon: '👑',
      rarity: 'legendary',
      xpReward: 1000,
    ),
    'speed_demon': Badge(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Won a battle in under 10 seconds',
      icon: '⚡',
      rarity: 'rare',
      xpReward: 300,
    ),
    'daily_trainer': Badge(
      id: 'daily_trainer',
      name: 'Daily Trainer',
      description: 'Trained for 7 consecutive days',
      icon: '📅',
      rarity: 'epic',
      xpReward: 500,
    ),
  };

  /// Get all unlocked badges
  Future<List<Badge>> getUnlockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final badgesJson = prefs.getString(_storageKey);

    if (badgesJson == null) return [];

    final List<dynamic> badgesList = jsonDecode(badgesJson);
    return badgesList.map((json) => Badge.fromJson(json)).toList();
  }

  /// Check if badge is unlocked
  Future<bool> isBadgeUnlocked(String badgeId) async {
    final badges = await getUnlockedBadges();
    return badges.any((badge) => badge.id == badgeId);
  }

  /// Unlock a badge
  Future<Badge?> unlockBadge(String badgeId) async {
    // Check if already unlocked
    if (await isBadgeUnlocked(badgeId)) {
      return null;
    }

    // Get badge template
    final badgeTemplate = availableBadges[badgeId];
    if (badgeTemplate == null) return null;

    // Create new badge instance
    final badge = Badge(
      id: badgeTemplate.id,
      name: badgeTemplate.name,
      description: badgeTemplate.description,
      icon: badgeTemplate.icon,
      rarity: badgeTemplate.rarity,
      xpReward: badgeTemplate.xpReward,
      unlockedAt: DateTime.now(),
    );

    // Save badge
    final badges = await getUnlockedBadges();
    badges.add(badge);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(badges.map((b) => b.toJson()).toList()),
    );

    return badge;
  }

  /// Get badge progress (e.g., for "win 50 battles")
  Future<double> getBadgeProgress(
    String badgeId,
    int currentValue,
    int targetValue,
  ) async {
    if (await isBadgeUnlocked(badgeId)) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Clear all badges (for testing)
  Future<void> clearBadges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
