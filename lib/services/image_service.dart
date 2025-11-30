import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final Dio _dio = Dio();

  /// Downloads an image from a URL and saves it locally
  /// Returns the local file path
  Future<String> downloadAndSaveImage(String imageUrl, String filename) async {
    try {
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/pokeagent_images');

      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Download image
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to file
      final file = File('${imagesDir.path}/$filename');
      await file.writeAsBytes(response.data!);

      return file.path;
    } catch (e) {
      // Return original URL as fallback
      return imageUrl;
    }
  }

  /// Gets a local image path if it exists, otherwise returns the URL
  Future<String> getImagePath(String imageUrl, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pokeagent_images/$filename');

      if (await file.exists()) {
        return file.path;
      }
      return imageUrl;
    } catch (e) {
      return imageUrl;
    }
  }

  /// Generates a filename from agent id and type
  String generateFilename(String agentId, String type) {
    return '${agentId}_${type.toLowerCase()}.png';
  }

  /// Downloads agent image and returns local path
  Future<String> downloadAgentImage(
    String imageUrl,
    String agentId,
    String type,
  ) async {
    final filename = generateFilename(agentId, type);
    return await downloadAndSaveImage(imageUrl, filename);
  }

  /// Clears all cached images
  Future<void> clearImageCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/pokeagent_images');

      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
      }
    } catch (e) {
      // Cache clearing failed
    }
  }

  /// Gets cache size in MB
  Future<double> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/pokeagent_images');

      if (!await imagesDir.exists()) return 0.0;

      int totalSize = 0;
      await for (var entity in imagesDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      return 0.0;
    }
  }
}
