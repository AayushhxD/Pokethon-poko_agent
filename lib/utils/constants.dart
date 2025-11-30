// App Constants
class AppConstants {
  // API Endpoints
  static const String baseApiUrl = 'https://your-backend.vercel.app/api';
  static const String mintEndpoint = '/mint';
  static const String chatEndpoint = '/chat';
  static const String battleEndpoint = '/battle';
  static const String evolveEndpoint = '/evolve';

  // Blockchain Configuration
  static const String ethSepoliaRpcUrl = 'https://rpc.sepolia.org';
  static const String baseSepoliaRpcUrl = 'https://sepolia.base.org';
  static const String baseMainnetRpcUrl = 'https://mainnet.base.org';
  static const int ethSepoliaChainId = 11155111;
  static const int baseSepoliaChainId = 84532;
  static const int baseMainnetChainId = 8453;

  // Contract Addresses (Update after deployment)
  static const String pokeAgentContractAddress =
      '0x149D84071CCB00913C96Db947fCb9000C1Da963C'; // Deployed on Ethereum Sepolia
  static const String battleContractAddress =
      '0x149D84071CCB00913C96Db947fCb9000C1Da963C'; // Deployed on Ethereum Sepolia

  // IPFS Configuration
  static const String ipfsGateway = 'https://ipfs.io/ipfs/';
  static const String nftStorageApiKey = 'YOUR_NFT_STORAGE_KEY';

  // Agent Types
  static const List<String> agentTypes = [
    'Fire',
    'Water',
    'Electric',
    'Psychic',
    'Grass',
    'Ice',
  ];

  // Evolution Thresholds
  static const int evolutionStage1XP = 100;
  static const int evolutionStage2XP = 300;
  static const int evolutionStage3XP = 600;

  // XP Rewards
  static const int chatXPReward = 5;
  static const int battleWinXPReward = 20;
  static const int battleLossXPReward = 5;
}
