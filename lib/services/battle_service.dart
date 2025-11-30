import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokeagent.dart';
import '../models/battle_models.dart';
import '../utils/constants.dart';

class BattleService extends ChangeNotifier {
  final Web3Client _client;
  final SharedPreferences _prefs;
  DeployedContract? _battleContract;

  // API URL for future backend integration
  // static const String _baseUrl = 'https://api.pokeagents.com';

  BattleService(this._prefs)
    : _client = Web3Client(AppConstants.ethSepoliaRpcUrl, http.Client());

  DeployedContract _getContract() {
    if (_battleContract != null) return _battleContract!;

    // Validate contract address before initialization
    if (AppConstants.battleContractAddress == '0x...' ||
        AppConstants.battleContractAddress ==
            '0x0000000000000000000000000000000000000000' ||
        AppConstants.battleContractAddress.isEmpty ||
        AppConstants.battleContractAddress.length < 42) {
      throw Exception(
        'Battle contract address not configured. Please deploy the BattleContract.sol and update AppConstants.battleContractAddress with the deployed address.',
      );
    }

    _initContract();
    return _battleContract!;
  }

  void _initContract() {
    // Battle contract ABI
    const contractAbi = '''
    [
      {
        "inputs": [
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"},
          {"internalType": "uint256", "name": "stakeAmount", "type": "uint256"},
          {"internalType": "bytes32", "name": "battleNonce", "type": "bytes32"}
        ],
        "name": "registerBattle",
        "outputs": [{"internalType": "uint256", "name": "battleId", "type": "uint256"}],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "battleId", "type": "uint256"},
          {"internalType": "bytes32", "name": "resultHash", "type": "bytes32"},
          {"internalType": "bytes", "name": "serverSig", "type": "bytes"}
        ],
        "name": "submitOffchainResult",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [{"internalType": "uint256", "name": "battleId", "type": "uint256"}],
        "name": "claimReward",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "owner", "type": "address"}
        ],
        "name": "getUserAgents",
        "outputs": [{"internalType": "uint256[]", "name": "", "type": "uint256[]"}],
        "stateMutability": "view",
        "type": "function"
      }
    ]
    ''';

    _battleContract = DeployedContract(
      ContractAbi.fromJson(contractAbi, 'BattleArena'),
      EthereumAddress.fromHex(AppConstants.battleContractAddress),
    );
  }

  // Get user's NFT agents from blockchain
  Future<List<PokeAgent>> getUserAgents(String walletAddress) async {
    try {
      // Return mock data immediately for demo (contract may not be deployed yet)
      debugPrint('📦 Loading agents for: $walletAddress');
      return _getMockAgents();

      /* Uncomment when contract is deployed and working:
      final contract = _getContract();
      // Ensure address is properly formatted (40 hex chars + 0x prefix)
      String formattedAddress = walletAddress.toLowerCase();
      if (formattedAddress.startsWith('0x')) {
        formattedAddress = formattedAddress.substring(2);
      }
      // Pad if too short
      if (formattedAddress.length < 40) {
        formattedAddress = formattedAddress.padRight(40, '0');
      }
      formattedAddress = '0x$formattedAddress';
      final address = EthereumAddress.fromHex(formattedAddress);
      final result = await _client.call(
        contract: contract,
        function: contract.function('getUserAgents'),
        params: [address],
      ).timeout(const Duration(seconds: 5));

      final tokenIds = result[0] as List<dynamic>;
      final agents = <PokeAgent>[];

      for (final tokenId in tokenIds) {
        try {
          final agent = await _getAgentDetails(tokenId as BigInt);
          if (agent != null) {
            agents.add(agent);
          }
        } catch (e) {
          debugPrint('Error loading agent $tokenId: $e');
        }
      }

      return agents.isNotEmpty ? agents : _getMockAgents();
      */
    } catch (e) {
      debugPrint('Error getting user agents: $e');
      // Return mock data for demo
      return _getMockAgents();
    }
  }

  // Note: _getAgentDetails is reserved for future production use with IPFS
  // Currently using mock data for demo
  /*
  Future<PokeAgent?> _getAgentDetails(BigInt tokenId) async {
    try {
      final contract = _getContract();
      // Get token URI
      await _client.call(
        contract: contract,
        function: contract.function('tokenURI'),
        params: [tokenId],
      );

      // In production, fetch metadata from IPFS
      // For demo, return mock data
      return PokeAgent(
        id: tokenId.toInt().toString(),
        name: 'PokéAgent #${tokenId.toInt()}',
        type: 'Fire',
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${(tokenId.toInt() % 150) + 1}.png',
        stats: {
          'hp': 100,
          'attack': 50,
          'defense': 40,
          'speed': 60,
          'special': 50,
        },
        tokenId: tokenId.toInt().toString(),
      );
    } catch (e) {
      debugPrint('Error getting agent details: $e');
      return null;
    }
  }
  */

  List<PokeAgent> _getMockAgents() {
    return [
      PokeAgent(
        id: '1',
        name: 'Charizard',
        type: 'Fire',
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png',
        stats: {
          'hp': 120,
          'attack': 85,
          'defense': 70,
          'speed': 90,
          'special': 80,
        },
        tokenId: '1',
        isFavorite: true,
      ),
      PokeAgent(
        id: '2',
        name: 'Blastoise',
        type: 'Water',
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png',
        stats: {
          'hp': 130,
          'attack': 75,
          'defense': 85,
          'speed': 65,
          'special': 75,
        },
        tokenId: '2',
        isFavorite: false,
      ),
      PokeAgent(
        id: '3',
        name: 'Venusaur',
        type: 'Grass',
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/3.png',
        stats: {
          'hp': 125,
          'attack': 80,
          'defense': 75,
          'speed': 70,
          'special': 85,
        },
        tokenId: '3',
        isFavorite: false,
      ),
    ];
  }

  // Create battle on-chain
  Future<int> createBattle(int tokenId, {int stakeAmount = 0}) async {
    try {
      // Return mock battle ID immediately for demo
      debugPrint('🎮 Creating battle for token: $tokenId');
      final battleId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _prefs.setInt('current_battle_id', battleId);

      // Simulate brief delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      return battleId;

      /* Uncomment when contract is deployed and working:
      // Generate battle nonce
      final battleNonce = _generateBattleNonce();

      final contract = _getContract();
      // Call smart contract
      final credentials = await _getCredentials();
      final result = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: contract.function('registerBattle'),
          parameters: [
            BigInt.from(tokenId),
            BigInt.from(stakeAmount),
            battleNonce,
          ],
        ),
        chainId: 11155111, // Ethereum Sepolia
      ).timeout(const Duration(seconds: 10));

      // Wait for transaction
      final receipt = await _client.getTransactionReceipt(result);
      if (receipt?.status != true) {
        throw Exception('Transaction failed');
      }

      // Extract battle ID from logs (simplified)
      final battleId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Store battle locally
      await _prefs.setInt('current_battle_id', battleId);
      await _prefs.setString('battle_nonce', battleNonce.toString());

      return battleId;
      */
    } catch (e) {
      debugPrint('Error creating battle: $e');
      throw Exception('Failed to create battle: $e');
    }
  }

  // Get battle status and find opponent
  Future<BattleStatus> getBattleStatus(int battleId) async {
    try {
      debugPrint('🎯 Getting battle status for: $battleId');

      // Return mock status immediately for demo
      await Future.delayed(const Duration(milliseconds: 300));

      // Pick random opponent from mock agents
      final mockAgents = _getMockAgents();
      final opponentAgent = mockAgents[1]; // Use Blastoise as opponent

      return BattleStatus(
        battleId: battleId,
        status: 'matched',
        opponent: BattleAgent(
          tokenId: opponentAgent.id.hashCode.abs(),
          name: opponentAgent.name,
          imageUrl: opponentAgent.imageUrl,
          level: opponentAgent.level,
          elementType: opponentAgent.type,
          hp: opponentAgent.stats['hp'] ?? 100,
          attack: opponentAgent.stats['attack'] ?? 60,
          defense: opponentAgent.stats['defense'] ?? 50,
          speed: opponentAgent.stats['speed'] ?? 80,
        ),
        arenaTheme: 'volcano',
        startTime: DateTime.now(),
      );

      /* Uncomment when backend is ready:
      final response = await http.get(
        Uri.parse('$_baseUrl/battle/status/$battleId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BattleStatus.fromJson(data);
      } else {
        throw Exception('Failed to get battle status');
      }
      */
    } catch (e) {
      debugPrint('Error getting battle status: $e');
      // Return mock status for demo
      return BattleStatus(
        battleId: battleId,
        status: 'matched',
        opponent: BattleAgent(
          tokenId: 999,
          name: 'AI Opponent',
          imageUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
          level: 15,
          elementType: 'Electric',
          hp: 100,
          attack: 60,
          defense: 50,
          speed: 80,
        ),
        arenaTheme: 'volcano',
        startTime: DateTime.now(),
      );
    }
  }

  // Simulate battle
  Future<BattleResult> simulateBattle(
    int battleId,
    BattleAgent myAgent,
    BattleAgent opponent,
  ) async {
    try {
      debugPrint('⚔️ Simulating battle: $battleId');

      // Return mock battle result immediately for demo
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockBattleResult(battleId, myAgent, opponent);

      /* Uncomment when backend is ready:
      final requestBody = {
        'battleId': battleId,
        'agent1': myAgent.toJson(),
        'agent2': opponent.toJson(),
        'seed': _prefs.getString('battle_nonce') ?? 'default_seed',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/battle/simulate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BattleResult.fromJson(data);
      } else {
        throw Exception('Failed to simulate battle');
      }
      */
    } catch (e) {
      debugPrint('Error simulating battle: $e');
      // Return mock battle result for demo
      return _getMockBattleResult(battleId, myAgent, opponent);
    }
  }

  // Submit battle result on-chain
  Future<void> submitBattleResult(
    int battleId,
    String resultHash,
    String serverSignature,
  ) async {
    try {
      final contract = _getContract();
      final credentials = await _getCredentials();

      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: contract.function('submitOffchainResult'),
          parameters: [BigInt.from(battleId), resultHash, serverSignature],
        ),
        chainId: 11155111, // Ethereum Sepolia
      );
    } catch (e) {
      debugPrint('Error submitting battle result: $e');
      throw Exception('Failed to submit battle result: $e');
    }
  }

  // Claim rewards
  Future<void> claimReward(int battleId) async {
    try {
      final contract = _getContract();
      final credentials = await _getCredentials();

      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: contract.function('claimReward'),
          parameters: [BigInt.from(battleId)],
        ),
        chainId: 11155111, // Ethereum Sepolia
      );
    } catch (e) {
      debugPrint('Error claiming reward: $e');
      throw Exception('Failed to claim reward: $e');
    }
  }

  // Helper methods
  // Note: _generateBattleNonce is reserved for future blockchain integration
  // Uint8List _generateBattleNonce() {
  //   final random = DateTime.now().millisecondsSinceEpoch.toString();
  //   final bytes = utf8.encode(random);
  //   final paddedBytes = Uint8List(32);
  //   for (int i = 0; i < bytes.length && i < 32; i++) {
  //     paddedBytes[i] = bytes[i];
  //   }
  //   return paddedBytes;
  // }

  Future<EthPrivateKey> _getCredentials() async {
    // TODO: Implement proper wallet connection using WalletConnect or similar
    // This should retrieve the private key securely from the user's connected wallet
    // NEVER store private keys in the app or use hardcoded test keys in production

    throw UnimplementedError(
      'Wallet connection not implemented. Please connect a Web3 wallet to sign transactions.',
    );

    // Example implementation with flutter_secure_storage:
    // final storage = FlutterSecureStorage();
    // final privateKeyHex = await storage.read(key: 'wallet_private_key');
    // if (privateKeyHex == null) {
    //   throw Exception('No wallet connected');
    // }
    // return EthPrivateKey.fromHex(privateKeyHex);
  }

  BattleResult _getMockBattleResult(
    int battleId,
    BattleAgent myAgent,
    BattleAgent opponent,
  ) {
    final turns = [
      BattleTurn(
        turnNumber: 1,
        attackerTokenId: myAgent.tokenId,
        defenderTokenId: opponent.tokenId,
        moveName: 'Fire Blast',
        moveType: 'Fire',
        damage: 25,
        remainingHp: 75,
        description: '${myAgent.name} used Fire Blast!',
      ),
      BattleTurn(
        turnNumber: 2,
        attackerTokenId: opponent.tokenId,
        defenderTokenId: myAgent.tokenId,
        moveName: 'Thunder Shock',
        moveType: 'Electric',
        damage: 20,
        remainingHp: 80,
        description: '${opponent.name} used Thunder Shock!',
      ),
      BattleTurn(
        turnNumber: 3,
        attackerTokenId: myAgent.tokenId,
        defenderTokenId: opponent.tokenId,
        moveName: 'Flame Wheel',
        moveType: 'Fire',
        damage: 30,
        remainingHp: 45,
        description: '${myAgent.name} used Flame Wheel!',
      ),
      BattleTurn(
        turnNumber: 4,
        attackerTokenId: opponent.tokenId,
        defenderTokenId: myAgent.tokenId,
        moveName: 'Quick Attack',
        moveType: 'Normal',
        damage: 15,
        remainingHp: 65,
        description: '${opponent.name} used Quick Attack!',
      ),
      BattleTurn(
        turnNumber: 5,
        attackerTokenId: myAgent.tokenId,
        defenderTokenId: opponent.tokenId,
        moveName: 'Inferno',
        moveType: 'Fire',
        damage: 50,
        remainingHp: 0,
        description: '${myAgent.name} used Inferno! Critical hit!',
      ),
    ];

    return BattleResult(
      battleId: battleId,
      winnerTokenId: myAgent.tokenId,
      loserTokenId: opponent.tokenId,
      turns: turns,
      resultHash: '0x1234567890abcdef',
      serverSignature: '0xsignature',
      rewardAmount: 10,
      rewardToken: 'PAGENT',
      isWinner: true,
    );
  }
}
