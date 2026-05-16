import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

class ModelManager {
  static final ModelManager instance = ModelManager._internal();
  ModelManager._internal();

  static const String modelFileName = 'gemma-4-E2B-it.litertlm';
  // Note: Using the resolve URL for direct download from Hugging Face
  static const String modelUrl = 'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm?download=true';

  Future<String> get localPath async {
    final directory = await getApplicationSupportDirectory();
    return p.join(directory.path, 'models', modelFileName);
  }

  Future<bool> isModelDownloaded() async {
    final path = await localPath;
    final file = File(path);
    if (await file.exists()) {
      // Check if file is non-empty (at least a few MB)
      final length = await file.length();
      return length > 10 * 1024 * 1024; // > 10MB as a safety check
    }
    return false;
  }

  Future<void> downloadModel({
    required Function(double progress) onProgress,
    required Function(String path) onComplete,
    required Function(String error) onError,
  }) async {
    try {
      final path = await localPath;
      
      // 1. Check for available space (Rough estimate)
      // On Android/iOS we can't easily get free space without a plugin, 
      // but we can catch the specific No Space error.
      
      // Ensure directory exists
      final dir = Directory(p.dirname(path));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final dio = Dio();
      
      // Using a more robust download link and adding options
      await dio.download(
        modelUrl,
        path + '.tmp',
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final tmpFile = File(path + '.tmp');
      if (await tmpFile.exists()) {
        await tmpFile.rename(path);
        onComplete(path);
      } else {
        onError('Downloaded file not found.');
      }
    } on DioException catch (e) {
      if (e.error is FileSystemException && e.error.toString().contains('No space left')) {
        onError('Insufficient storage space. Please free up at least 3GB.');
      } else {
        onError('Download failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Model download error: $e');
      onError(e.toString());
    }
  }

  Future<void> deleteModel() async {
    final path = await localPath;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
