import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class BlockchainService {
  late Web3Client _client;
  late DeployedContract _contract;

  BlockchainService() {
    _client = Web3Client(AppConstants.baseSepoliaRpcUrl, http.Client());
    _initContract();
  }

  void _initContract() {
    // Simple ERC-721 ABI for minting
    const contractAbi = '''
    [
      {
        "inputs": [
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "string", "name": "tokenURI", "type": "string"}
        ],
        "name": "mint",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [{"internalType": "uint256", "name": "tokenId", "type": "uint256"}],
        "name": "tokenURI",
        "outputs": [{"internalType": "string", "name": "", "type": "string"}],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [{"internalType": "address", "name": "owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
      }
    ]
    ''';

    _contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, 'PokeAgent'),
      EthereumAddress.fromHex(AppConstants.pokeAgentContractAddress),
    );
  }

  // Mint NFT
  Future<String> mintAgent({
    required String walletAddress,
    required String metadataUri,
    required String privateKey,
  }) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final mintFunction = _contract.function('mint');

      final transaction = Transaction.callContract(
        contract: _contract,
        function: mintFunction,
        parameters: [EthereumAddress.fromHex(walletAddress), metadataUri],
      );

      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: AppConstants.baseSepoliaChainId,
      );

      return txHash;
    } catch (e) {
      throw Exception('Failed to mint NFT: $e');
    }
  }

  // Get Token URI
  Future<String> getTokenUri(int tokenId) async {
    try {
      final function = _contract.function('tokenURI');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [BigInt.from(tokenId)],
      );

      return result.first as String;
    } catch (e) {
      throw Exception('Failed to get token URI: $e');
    }
  }

  // Get Balance
  Future<int> getBalance(String walletAddress) async {
    try {
      final function = _contract.function('balanceOf');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [EthereumAddress.fromHex(walletAddress)],
      );

      return (result.first as BigInt).toInt();
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  // Get Chain ID
  Future<int> getChainId() async {
    try {
      final chainId = await _client.getChainId();
      return chainId.toInt();
    } catch (e) {
      throw Exception('Failed to get chain ID: $e');
    }
  }

  void dispose() {
    _client.dispose();
  }
}
