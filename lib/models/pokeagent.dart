class PokeAgent {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final int xp;
  final int evolutionStage;
  final String personality;
  final Map<String, int> stats;
  final String? tokenId;
  final String? contractAddress;
  final DateTime createdAt;
  final DateTime? lastInteraction;
  final String mood; // happy, tired, angry, excited, sad
  final int moodLevel; // 0-100
  final List<String> badges; // Achievement badges
  final int battlesWon;
  final int battlesLost;
  final int totalChats;

  PokeAgent({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    this.xp = 0,
    this.evolutionStage = 1,
    this.personality = 'Friendly',
    Map<String, int>? stats,
    this.tokenId,
    this.contractAddress,
    DateTime? createdAt,
    this.lastInteraction,
    this.mood = 'happy',
    this.moodLevel = 80,
    List<String>? badges,
    this.battlesWon = 0,
    this.battlesLost = 0,
    this.totalChats = 0,
  }) : stats = stats ?? _defaultStats(type),
       badges = badges ?? [],
       createdAt = createdAt ?? DateTime.now();

  static Map<String, int> _defaultStats(String type) {
    return {'hp': 100, 'attack': 50, 'defense': 50, 'speed': 50, 'special': 50};
  }

  int get level => (evolutionStage * 10) + (xp ~/ 100);

  double get xpProgress {
    int currentStageXP = _getStageXP(evolutionStage);
    int nextStageXP = _getStageXP(evolutionStage + 1);
    if (nextStageXP == currentStageXP) return 1.0;
    return ((xp - currentStageXP) / (nextStageXP - currentStageXP)).clamp(
      0.0,
      1.0,
    );
  }

  bool get canEvolve =>
      xp >= _getStageXP(evolutionStage + 1) && evolutionStage < 3;

  int _getStageXP(int stage) {
    switch (stage) {
      case 1:
        return 0;
      case 2:
        return 100;
      case 3:
        return 300;
      case 4:
        return 600;
      default:
        return 600;
    }
  }

  // Calculate mood based on last interaction
  String get currentMood {
    if (lastInteraction == null) return mood;
    final hoursSinceLastInteraction =
        DateTime.now().difference(lastInteraction!).inHours;
    if (hoursSinceLastInteraction > 24) return 'sad';
    if (hoursSinceLastInteraction > 12) return 'tired';
    return mood;
  }

  // Get mood emoji
  String get moodEmoji {
    switch (currentMood) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🤩';
      case 'angry':
        return '😠';
      case 'tired':
        return '😴';
      case 'sad':
        return '😢';
      default:
        return '😊';
    }
  }

  // Calculate win rate
  double get winRate {
    final totalBattles = battlesWon + battlesLost;
    if (totalBattles == 0) return 0.0;
    return (battlesWon / totalBattles * 100);
  }

  PokeAgent copyWith({
    String? id,
    String? name,
    String? type,
    String? imageUrl,
    int? xp,
    int? evolutionStage,
    String? personality,
    Map<String, int>? stats,
    String? tokenId,
    String? contractAddress,
    DateTime? createdAt,
    DateTime? lastInteraction,
    String? mood,
    int? moodLevel,
    List<String>? badges,
    int? battlesWon,
    int? battlesLost,
    int? totalChats,
  }) {
    return PokeAgent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      xp: xp ?? this.xp,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      personality: personality ?? this.personality,
      stats: stats ?? this.stats,
      tokenId: tokenId ?? this.tokenId,
      contractAddress: contractAddress ?? this.contractAddress,
      createdAt: createdAt ?? this.createdAt,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      mood: mood ?? this.mood,
      moodLevel: moodLevel ?? this.moodLevel,
      badges: badges ?? this.badges,
      battlesWon: battlesWon ?? this.battlesWon,
      battlesLost: battlesLost ?? this.battlesLost,
      totalChats: totalChats ?? this.totalChats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
      'xp': xp,
      'evolutionStage': evolutionStage,
      'personality': personality,
      'stats': stats,
      'tokenId': tokenId,
      'contractAddress': contractAddress,
      'createdAt': createdAt.toIso8601String(),
      'lastInteraction': lastInteraction?.toIso8601String(),
      'mood': mood,
      'moodLevel': moodLevel,
      'badges': badges,
      'battlesWon': battlesWon,
      'battlesLost': battlesLost,
      'totalChats': totalChats,
    };
  }

  factory PokeAgent.fromJson(Map<String, dynamic> json) {
    return PokeAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String,
      xp: json['xp'] as int? ?? 0,
      evolutionStage: json['evolutionStage'] as int? ?? 1,
      personality: json['personality'] as String? ?? 'Friendly',
      stats: Map<String, int>.from(json['stats'] as Map? ?? {}),
      tokenId: json['tokenId'] as String?,
      contractAddress: json['contractAddress'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastInteraction:
          json['lastInteraction'] != null
              ? DateTime.parse(json['lastInteraction'] as String)
              : null,
      mood: json['mood'] as String? ?? 'happy',
      moodLevel: json['moodLevel'] as int? ?? 80,
      badges: List<String>.from(json['badges'] as List? ?? []),
      battlesWon: json['battlesWon'] as int? ?? 0,
      battlesLost: json['battlesLost'] as int? ?? 0,
      totalChats: json['totalChats'] as int? ?? 0,
    );
  }
}
