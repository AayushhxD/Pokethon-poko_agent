class BattleAgent {
  final int tokenId;
  final String name;
  final String imageUrl;
  final int level;
  final String elementType;
  final int hp;
  final int attack;
  final int defense;
  final int speed;

  const BattleAgent({
    required this.tokenId,
    required this.name,
    required this.imageUrl,
    required this.level,
    required this.elementType,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
  });

  factory BattleAgent.fromJson(Map<String, dynamic> json) {
    return BattleAgent(
      tokenId: json['tokenId'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      level: json['level'] as int,
      elementType: json['elementType'] as String,
      hp: json['hp'] as int,
      attack: json['attack'] as int,
      defense: json['defense'] as int,
      speed: json['speed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'name': name,
      'imageUrl': imageUrl,
      'level': level,
      'elementType': elementType,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'speed': speed,
    };
  }
}

class BattleTurn {
  final int turnNumber;
  final int attackerTokenId;
  final int defenderTokenId;
  final String moveName;
  final String moveType;
  final int damage;
  final int remainingHp;
  final String description;

  const BattleTurn({
    required this.turnNumber,
    required this.attackerTokenId,
    required this.defenderTokenId,
    required this.moveName,
    required this.moveType,
    required this.damage,
    required this.remainingHp,
    required this.description,
  });

  factory BattleTurn.fromJson(Map<String, dynamic> json) {
    return BattleTurn(
      turnNumber: json['turnNumber'] as int,
      attackerTokenId: json['attackerTokenId'] as int,
      defenderTokenId: json['defenderTokenId'] as int,
      moveName: json['moveName'] as String,
      moveType: json['moveType'] as String,
      damage: json['damage'] as int,
      remainingHp: json['remainingHp'] as int,
      description: json['description'] as String,
    );
  }
}

class BattleResult {
  final int battleId;
  final int winnerTokenId;
  final int loserTokenId;
  final List<BattleTurn> turns;
  final String resultHash;
  final String serverSignature;
  final int rewardAmount;
  final String rewardToken;
  final bool isWinner;

  const BattleResult({
    required this.battleId,
    required this.winnerTokenId,
    required this.loserTokenId,
    required this.turns,
    required this.resultHash,
    required this.serverSignature,
    required this.rewardAmount,
    required this.rewardToken,
    required this.isWinner,
  });

  factory BattleResult.fromJson(Map<String, dynamic> json) {
    return BattleResult(
      battleId: json['battleId'] as int,
      winnerTokenId: json['winnerTokenId'] as int,
      loserTokenId: json['loserTokenId'] as int,
      turns:
          (json['turns'] as List<dynamic>)
              .map((turn) => BattleTurn.fromJson(turn as Map<String, dynamic>))
              .toList(),
      resultHash: json['resultHash'] as String,
      serverSignature: json['serverSignature'] as String,
      rewardAmount: json['rewardAmount'] as int,
      rewardToken: json['rewardToken'] as String,
      isWinner: json['isWinner'] as bool,
    );
  }
}

class BattleStatus {
  final int battleId;
  final String status; // 'waiting', 'matched', 'in_progress', 'completed'
  final BattleAgent? opponent;
  final String? arenaTheme;
  final DateTime? startTime;

  const BattleStatus({
    required this.battleId,
    required this.status,
    this.opponent,
    this.arenaTheme,
    this.startTime,
  });

  factory BattleStatus.fromJson(Map<String, dynamic> json) {
    return BattleStatus(
      battleId: json['battleId'] as int,
      status: json['status'] as String,
      opponent:
          json['opponent'] != null
              ? BattleAgent.fromJson(json['opponent'] as Map<String, dynamic>)
              : null,
      arenaTheme: json['arenaTheme'] as String?,
      startTime:
          json['startTime'] != null
              ? DateTime.parse(json['startTime'] as String)
              : null,
    );
  }
}
