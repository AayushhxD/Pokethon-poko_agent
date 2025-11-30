import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int targetProgress;
  final int currentProgress;
  final int rewardPoko;
  final int rewardXp;
  final ChallengeType type;
  final bool isCompleted;
  final bool isRewardClaimed;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetProgress,
    required this.currentProgress,
    required this.rewardPoko,
    required this.rewardXp,
    required this.type,
    this.isCompleted = false,
    this.isRewardClaimed = false,
  });

  double get progressPercentage =>
      targetProgress > 0
          ? (currentProgress / targetProgress).clamp(0.0, 1.0)
          : 0.0;

  DailyChallenge copyWith({
    int? currentProgress,
    bool? isCompleted,
    bool? isRewardClaimed,
  }) {
    return DailyChallenge(
      id: id,
      title: title,
      description: description,
      icon: icon,
      targetProgress: targetProgress,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardPoko: rewardPoko,
      rewardXp: rewardXp,
      type: type,
      isCompleted: isCompleted ?? this.isCompleted,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'targetProgress': targetProgress,
    'currentProgress': currentProgress,
    'rewardPoko': rewardPoko,
    'rewardXp': rewardXp,
    'type': type.index,
    'isCompleted': isCompleted,
    'isRewardClaimed': isRewardClaimed,
  };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) => DailyChallenge(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    icon: json['icon'],
    targetProgress: json['targetProgress'],
    currentProgress: json['currentProgress'],
    rewardPoko: json['rewardPoko'],
    rewardXp: json['rewardXp'],
    type: ChallengeType.values[json['type']],
    isCompleted: json['isCompleted'] ?? false,
    isRewardClaimed: json['isRewardClaimed'] ?? false,
  );
}

enum ChallengeType {
  battle,
  catch_pokemon,
  train,
  evolve,
  mint,
  win_streak,
  marketplace,
}

class DailyChallengeService extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<DailyChallenge> _challenges = [];
  int _totalChallengesCompleted = 0;

  DailyChallengeService(this._prefs) {
    _loadChallenges();
  }

  List<DailyChallenge> get challenges => _challenges;
  int get completedCount => _challenges.where((c) => c.isCompleted).length;
  int get totalChallengesCompleted => _totalChallengesCompleted;
  bool get allCompleted =>
      _challenges.isNotEmpty && _challenges.every((c) => c.isCompleted);

  Future<void> _loadChallenges() async {
    final lastRefresh = _prefs.getString('challenges_last_refresh');
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    _totalChallengesCompleted =
        _prefs.getInt('total_challenges_completed') ?? 0;

    if (lastRefresh != todayString) {
      // New day - generate new challenges
      await _generateDailyChallenges();
      await _prefs.setString('challenges_last_refresh', todayString);
    } else {
      // Load existing challenges
      final challengesJson = _prefs.getStringList('daily_challenges') ?? [];
      if (challengesJson.isEmpty) {
        await _generateDailyChallenges();
      } else {
        _challenges =
            challengesJson
                .map((json) => DailyChallenge.fromJson(jsonDecode(json)))
                .toList();
      }
    }
    notifyListeners();
  }

  Future<void> _generateDailyChallenges() async {
    _challenges = [
      DailyChallenge(
        id: 'battle_3',
        title: 'Battle Master',
        description: 'Win 3 battles today',
        icon: '⚔️',
        targetProgress: 3,
        currentProgress: 0,
        rewardPoko: 50,
        rewardXp: 100,
        type: ChallengeType.battle,
      ),
      DailyChallenge(
        id: 'catch_2',
        title: 'Pokemon Hunter',
        description: 'Catch 2 wild Pokemon',
        icon: '🎯',
        targetProgress: 2,
        currentProgress: 0,
        rewardPoko: 30,
        rewardXp: 60,
        type: ChallengeType.catch_pokemon,
      ),
      DailyChallenge(
        id: 'train_5',
        title: 'Dedicated Trainer',
        description: 'Train your agents 5 times',
        icon: '📚',
        targetProgress: 5,
        currentProgress: 0,
        rewardPoko: 25,
        rewardXp: 75,
        type: ChallengeType.train,
      ),
      DailyChallenge(
        id: 'win_streak_2',
        title: 'On Fire!',
        description: 'Get a 2 win streak',
        icon: '🔥',
        targetProgress: 2,
        currentProgress: 0,
        rewardPoko: 40,
        rewardXp: 80,
        type: ChallengeType.win_streak,
      ),
      DailyChallenge(
        id: 'mint_1',
        title: 'Creator',
        description: 'Mint a new agent',
        icon: '✨',
        targetProgress: 1,
        currentProgress: 0,
        rewardPoko: 20,
        rewardXp: 50,
        type: ChallengeType.mint,
      ),
    ];
    await _saveChallenges();
  }

  Future<void> _saveChallenges() async {
    final challengesJson =
        _challenges.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList('daily_challenges', challengesJson);
    await _prefs.setInt(
      'total_challenges_completed',
      _totalChallengesCompleted,
    );
  }

  Future<void> updateProgress(ChallengeType type, {int amount = 1}) async {
    bool updated = false;

    for (int i = 0; i < _challenges.length; i++) {
      final challenge = _challenges[i];
      if (challenge.type == type && !challenge.isCompleted) {
        final newProgress = (challenge.currentProgress + amount).clamp(
          0,
          challenge.targetProgress,
        );
        final isNowCompleted = newProgress >= challenge.targetProgress;

        _challenges[i] = challenge.copyWith(
          currentProgress: newProgress,
          isCompleted: isNowCompleted,
        );

        if (isNowCompleted && !challenge.isCompleted) {
          _totalChallengesCompleted++;
        }

        updated = true;
      }
    }

    if (updated) {
      await _saveChallenges();
      notifyListeners();
    }
  }

  Future<Map<String, int>> claimReward(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return {'poko': 0, 'xp': 0};

    final challenge = _challenges[index];
    if (!challenge.isCompleted || challenge.isRewardClaimed) {
      return {'poko': 0, 'xp': 0};
    }

    _challenges[index] = challenge.copyWith(isRewardClaimed: true);
    await _saveChallenges();
    notifyListeners();

    return {'poko': challenge.rewardPoko, 'xp': challenge.rewardXp};
  }

  Future<void> refreshChallenges() async {
    await _generateDailyChallenges();
    notifyListeners();
  }
}
