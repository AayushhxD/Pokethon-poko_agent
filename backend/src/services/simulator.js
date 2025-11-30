const { ethers } = require('ethers');
const crypto = require('crypto');

/**
 * Deterministic Battle Simulator
 * Same logic as Unity BattleManager.cs
 * Uses seeded RNG for reproducible results
 */
class BattleSimulator {
  constructor(seed) {
    this.seed = seed;
    this.rng = this.createSeededRNG(seed);
  }

  /**
   * Create seeded RNG using crypto
   */
  createSeededRNG(seed) {
    const hash = crypto.createHash('sha256').update(seed).digest();
    let index = 0;
    
    return () => {
      if (index >= hash.length) {
        index = 0;
      }
      return hash[index++] / 255;
    };
  }

  /**
   * Generate deterministic battle turns
   */
  simulate(playerAgent, opponentAgent) {
    const turns = [];
    let playerHp = playerAgent.hp;
    let opponentHp = opponentAgent.hp;
    let turnNumber = 1;
    const maxTurns = 20;

    // Determine first attacker
    let playerFirst = playerAgent.speed >= opponentAgent.speed;
    if (playerAgent.speed === opponentAgent.speed) {
      playerFirst = this.rng() < 0.5;
    }

    while (playerHp > 0 && opponentHp > 0 && turnNumber <= maxTurns) {
      const playerTurn = (turnNumber % 2 === 1) ? playerFirst : !playerFirst;

      if (playerTurn) {
        // Player attacks
        const turn = this.simulateAttack(
          playerAgent,
          opponentAgent,
          opponentHp,
          turnNumber,
          true
        );
        opponentHp = turn.remainingHp;
        turns.push(turn);
      } else {
        // Opponent attacks
        const turn = this.simulateAttack(
          opponentAgent,
          playerAgent,
          playerHp,
          turnNumber,
          false
        );
        playerHp = turn.remainingHp;
        turns.push(turn);
      }

      turnNumber++;

      if (playerHp <= 0 || opponentHp <= 0) break;
    }

    // Determine winner
    const winnerTokenId = playerHp > 0 ? playerAgent.tokenId : opponentAgent.tokenId;

    return {
      winnerTokenId,
      turns,
      finalPlayerHp: playerHp,
      finalOpponentHp: opponentHp,
    };
  }

  /**
   * Simulate single attack
   * Damage formula: max(1, attack - defense/4) * randomFactor(0.85-1.0)
   */
  simulateAttack(attacker, defender, defenderHp, turnNumber, isPlayer) {
    // Base damage calculation
    const baseDamage = Math.max(1, attacker.attack - defender.defense / 4);
    
    // Random factor (0.85 to 1.0)
    const randomFactor = 0.85 + this.rng() * 0.15;
    
    // Final damage
    const damage = Math.round(baseDamage * randomFactor);
    
    // Apply damage
    const remainingHp = Math.max(0, defenderHp - damage);

    // Select move (simplified)
    const moveName = attacker.moves && attacker.moves.length > 0
      ? attacker.moves[Math.floor(this.rng() * attacker.moves.length)]
      : 'Basic Attack';

    return {
      turnNumber,
      attackerTokenId: attacker.tokenId,
      defenderTokenId: defender.tokenId,
      moveName,
      moveType: attacker.elementType || 'Normal',
      damage,
      remainingHp,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Create result hash for on-chain verification
   */
  static createResultHash(battleId, winnerTokenId, seed) {
    return ethers.utils.solidityKeccak256(
      ['uint256', 'uint256', 'string'],
      [battleId, winnerTokenId, seed]
    );
  }

  /**
   * Sign result hash with server private key
   */
  static signResult(resultHash, privateKey) {
    const wallet = new ethers.Wallet(privateKey);
    const messageHash = ethers.utils.arrayify(resultHash);
    return wallet.signMessage(messageHash);
  }

  /**
   * Verify signature
   */
  static verifySignature(resultHash, signature, expectedAddress) {
    const messageHash = ethers.utils.arrayify(resultHash);
    const recoveredAddress = ethers.utils.verifyMessage(messageHash, signature);
    return recoveredAddress.toLowerCase() === expectedAddress.toLowerCase();
  }
}

module.exports = BattleSimulator;
