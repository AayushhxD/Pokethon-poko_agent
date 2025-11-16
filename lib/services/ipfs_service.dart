import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/pokeagent.dart';

class IPFSService {
  final Dio _dio = Dio();

  // Upload metadata to IPFS (via NFT.storage or your backend)
  Future<String> uploadMetadata(PokeAgent agent) async {
    try {
      // In production, this would contain the metadata to upload
      // ignore: unused_local_variable
      final metadata = {
        'name': agent.name,
        'description':
            'PokéAgent ${agent.name} - A ${agent.type} type agent at stage ${agent.evolutionStage}',
        'image': agent.imageUrl,
        'attributes': [
          {'trait_type': 'Type', 'value': agent.type},
          {'trait_type': 'Evolution Stage', 'value': agent.evolutionStage},
          {'trait_type': 'XP', 'value': agent.xp},
          {'trait_type': 'Level', 'value': agent.level},
          {'trait_type': 'Personality', 'value': agent.personality},
          {'trait_type': 'HP', 'value': agent.stats['hp']},
          {'trait_type': 'Attack', 'value': agent.stats['attack']},
          {'trait_type': 'Defense', 'value': agent.stats['defense']},
          {'trait_type': 'Speed', 'value': agent.stats['speed']},
          {'trait_type': 'Special', 'value': agent.stats['special']},
        ],
      };

      // In production, upload to NFT.storage or IPFS
      // For now, return a mock IPFS hash
      final mockHash = 'Qm${_generateRandomHash()}';
      return 'ipfs://$mockHash';

      /* Production code:
      final response = await _dio.post(
        'https://api.nft.storage/upload',
        data: jsonEncode(metadata),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.nftStorageApiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      return 'ipfs://${response.data['value']['cid']}';
      */
    } catch (e) {
      throw Exception('Failed to upload to IPFS: $e');
    }
  }

  // Upload image to IPFS
  Future<String> uploadImage(List<int> imageBytes, String filename) async {
    try {
      // In production, upload to NFT.storage or IPFS
      final mockHash = 'Qm${_generateRandomHash()}';
      return '${AppConstants.ipfsGateway}$mockHash';

      /* Production code:
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: filename,
        ),
      });
      
      final response = await _dio.post(
        'https://api.nft.storage/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.nftStorageApiKey}',
          },
        ),
      );
      
      return '${AppConstants.ipfsGateway}${response.data['value']['cid']}';
      */
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Fetch metadata from IPFS
  Future<Map<String, dynamic>> fetchMetadata(String ipfsUri) async {
    try {
      final hash = ipfsUri.replaceAll('ipfs://', '');
      final url = '${AppConstants.ipfsGateway}$hash';

      final response = await _dio.get(url);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch from IPFS: $e');
    }
  }

  String _generateRandomHash() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      46,
      (index) => chars[DateTime.now().millisecondsSinceEpoch % chars.length],
    ).join();
  }
}
