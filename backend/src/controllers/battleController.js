const BattleSimulator = require('../services/simulator');
const crypto = require('../services/crypto');
const { ethers } = require('ethers');

/**
 * Battle Controller
 * Handles all battle-related API endpoints
 */

/**
 * @desc Create battle intent
 * @route POST /api/battle/create
 */
exports.createBattle = async (req, res) => {
  try {
    const { playerTokenId, opponentTokenId, stake } = req.body;

    // Validate input
    if (!playerTokenId) {
      return res.status(400).json({ error: 'playerTokenId is required' });
    }

    // Generate battle ID
    const battleId = Math.floor(Math.random() * 1000000);

    // Create transaction data for on-chain registration
    const txData = {
      to: process.env.BATTLE_CONTRACT_ADDRESS,
      data: encodeBattleRegistration(battleId, playerTokenId, stake || 0),
      value: '0',
    };

    // Store battle intent in database (if using DB)
    // await Battle.create({ battleId, playerTokenId, opponentTokenId, stake });

    res.json({
      success: true,
      battleId,
      txData,
      message: 'Battle intent created. Please register on-chain.',
    });
  } catch (error) {
    console.error('Error creating battle:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @desc Simulate battle and sign result
 * @route POST /api/battle/simulate
 */
exports.simulateBattle = async (req, res) => {
  try {
    const { battleId, seed, playerAgent, opponentAgent } = req.body;

    // Validate input
    if (!battleId || !seed || !playerAgent || !opponentAgent) {
      return res.status(400).json({ 
        error: 'Missing required fields: battleId, seed, playerAgent, opponentAgent' 
      });
    }

    console.log(`🎮 Simulating battle ${battleId} with seed: ${seed}`);

    // Run deterministic simulation
    const simulator = new BattleSimulator(seed);
    const result = simulator.simulate(playerAgent, opponentAgent);

    // Create result data
    const resultData = {
      battleId,
      winnerTokenId: result.winnerTokenId,
      turns: result.turns,
      seed,
      timestamp: new Date().toISOString(),
    };

    // Create result hash
    const resultHash = BattleSimulator.createResultHash(
      battleId,
      result.winnerTokenId,
      seed
    );

    // Sign result hash
    const signature = BattleSimulator.signResult(
      resultHash,
      process.env.SERVER_PRIVATE_KEY
    );

    // Get server address for verification
    const serverWallet = new ethers.Wallet(process.env.SERVER_PRIVATE_KEY);
    const serverAddress = serverWallet.address;

    console.log(`✅ Battle simulated. Winner: ${result.winnerTokenId}`);

    res.json({
      success: true,
      result: resultData,
      resultHash,
      signature,
      serverAddress,
      verification: {
        battleId,
        winnerTokenId: result.winnerTokenId,
        seed,
        turns: result.turns.length,
      },
    });
  } catch (error) {
    console.error('Error simulating battle:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @desc Store battle result and upload to IPFS
 * @route POST /api/battle/result
 */
exports.storeBattleResult = async (req, res) => {
  try {
    const { battleId, result, replayData } = req.body;

    if (!battleId || !result) {
      return res.status(400).json({ error: 'battleId and result are required' });
    }

    // Store in database (if using DB)
    // await BattleResult.create({ battleId, result, replayData });

    // Upload replay to IPFS (optional)
    let replayUrl = null;
    if (replayData && process.env.NFT_STORAGE_KEY) {
      // replayUrl = await uploadToIPFS(replayData);
      replayUrl = `ipfs://QmExample${battleId}`; // Placeholder
    }

    console.log(`✅ Battle result stored for battleId: ${battleId}`);

    res.json({
      success: true,
      battleId,
      replayUrl,
      message: 'Battle result stored successfully',
    });
  } catch (error) {
    console.error('Error storing battle result:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @desc Get battle details
 * @route GET /api/battle/:battleId
 */
exports.getBattle = async (req, res) => {
  try {
    const { battleId } = req.params;

    // Fetch from database (if using DB)
    // const battle = await Battle.findOne({ battleId });

    // Mock response
    res.json({
      success: true,
      battle: {
        battleId: parseInt(battleId),
        status: 'completed',
        playerTokenId: 123,
        opponentTokenId: 456,
        winnerTokenId: 123,
      },
    });
  } catch (error) {
    console.error('Error fetching battle:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @desc Get battle status
 * @route GET /api/battle/:battleId/status
 */
exports.getBattleStatus = async (req, res) => {
  try {
    const { battleId } = req.params;

    // Mock response
    res.json({
      success: true,
      status: 'matched',
      battleId: parseInt(battleId),
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error fetching battle status:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * Helper: Encode battle registration data
 */
function encodeBattleRegistration(battleId, playerTokenId, stake) {
  const iface = new ethers.utils.Interface([
    'function registerBattle(uint256 battleId, uint256 playerTokenId, uint256 stake)',
  ]);
  
  return iface.encodeFunctionData('registerBattle', [
    battleId,
    playerTokenId,
    stake,
  ]);
}

/**
 * Helper: Upload to IPFS (placeholder)
 */
async function uploadToIPFS(data) {
  // Implement IPFS upload using NFT.Storage or Pinata
  // const client = new NFTStorage({ token: process.env.NFT_STORAGE_KEY });
  // const cid = await client.storeBlob(new Blob([JSON.stringify(data)]));
  // return `ipfs://${cid}`;
  return `ipfs://QmExample${Date.now()}`;
}
