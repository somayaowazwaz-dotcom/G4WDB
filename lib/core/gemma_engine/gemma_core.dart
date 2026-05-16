import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'native_bindings.dart';
import '../services/model_manager.dart';

class GemmaCore extends ChangeNotifier {
  static final GemmaCore instance = GemmaCore._internal();
  Interpreter? _interpreter;
  bool _isInitialized = false;
  String? _localModelPath;

  // Model specs
  static const int modelSizeMB = 486;
  static const int contextWindow = 128 * 1024; // 128K tokens
  static const int parameters = 2600000000; // 2.6B

  GemmaCore._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // On Windows, we'll simulate a "loaded" state for demo purposes if the asset exists
    // since the real TFLite DLL might be missing in the environment.
    if (Platform.isWindows && !kReleaseMode) {
      debugPrint('ℹ️ Simulating Gemma Core on Windows for development');
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      // 1. Try to use downloaded model first
      final modelManager = ModelManager.instance;
      final hasDownloaded = await modelManager.isModelDownloaded();
      
      if (hasDownloaded) {
        _localModelPath = await modelManager.localPath;
        debugPrint('📦 Loading downloaded model from: $_localModelPath');
        
        try {
          _interpreter = await Interpreter.fromFile(
            File(_localModelPath!),
            options: InterpreterOptions()..threads = 4,
          );
        } catch (e) {
          debugPrint('❌ Error loading downloaded model: $e. It might be corrupted.');
          // If loading fails, delete it so the user can re-download
          await modelManager.deleteModel();
          rethrow;
        }
      } else {
        // 2. Fallback to assets (for dev)
        const modelAssetPath = 'assets/models/gemma-4-E2B-it.litertlm';
        debugPrint('📦 Attempting fallback to bundled asset: $modelAssetPath');
        
        _interpreter = await Interpreter.fromAsset(
          modelAssetPath,
          options: InterpreterOptions()..threads = 4,
        );
      }

      // Initialize native bindings for GPU delegate
      await NativeBindings.initialize();

      _isInitialized = true;
      debugPrint('✅ Gemma 4 E2B Core initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Warning: Gemma Core initialization failed: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> infer({
    required String prompt,
    List<String>? images,
    double temperature = 0.7,
    int maxTokens = 512,
  }) async {
    if (!_isInitialized) {
      throw Exception('Gemma Core not initialized');
    }

    final startTime = DateTime.now();

    try {
      // Prepare input tensors
      final inputTensor = await _prepareInput(prompt, images);

      String output;
      if (_interpreter != null) {
        // Run real inference using TFLite interpreter
        // Note: For LLMs like Gemma, this usually involves a loop generating tokens.
        // This is a simplified integration point.
        var outputBuffer =
            List<double>.filled(maxTokens, 0).reshape([1, maxTokens]);
        _interpreter!.run(inputTensor, outputBuffer);
        output =
            'Gemma Inference Result (from TFLite): ${outputBuffer.toString().substring(0, 50)}...';
      } else {
        // Fallback to native bindings / mock
        output = await NativeBindings.runInference(
          prompt: prompt,
          temperature: temperature,
          maxTokens: maxTokens,
        );
      }

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      debugPrint('⚡ Inference completed in ${latency}ms');

      return {
        'output': output,
        'latency_ms': latency,
        'tokens_generated': output.split(' ').length,
      };
    } catch (e) {
      debugPrint('❌ Inference error: $e');
      rethrow;
    }
  }

  Future<List<double>> _prepareInput(
      String prompt, List<String>? images) async {
    final tokens = _tokenize(prompt);

    if (images != null && images.isNotEmpty) {
      final imageEmbeddings = await _processImages(images);
      return _createMultimodalTensor(tokens, imageEmbeddings);
    }

    return tokens.map((e) => e.toDouble()).toList();
  }

  List<int> _tokenize(String text) {
    // Implement tokenization (using SentencePiece or similar)
    // This is a simplified version
    return text.codeUnits;
  }

  Future<List<double>> _processImages(List<String> imagePaths) async {
    final embeddings = <double>[];

    for (final imagePath in imagePaths) {
      debugPrint('Processing image for embeddings: $imagePath');
      embeddings.addAll(List<double>.filled(128, 0.0));
    }

    return embeddings;
  }

  List<double> _createMultimodalTensor(
      List<int> tokens, List<double> imageEmbeddings) {
    final combined = [...imageEmbeddings, ...tokens.map((e) => e.toDouble())];
    return combined;
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    NativeBindings.dispose();
    _isInitialized = false;
    super.dispose();
  }

  bool get isInitialized => _isInitialized;
}

final gemmaCoreProvider = ChangeNotifierProvider<GemmaCore>((ref) {
  return GemmaCore.instance;
});
