import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/gemma_engine/gemma_core.dart';
import '../../core/database/uxo_database.dart';
import '../../models/uxo_detection.dart';

class UXORecognitionAgent extends ChangeNotifier {
  final GemmaCore _gemmaCore = GemmaCore.instance;
  final UXODatabase _uxoDb = UXODatabase();
  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _simulationMode = false;
  UXODetection? _currentDetection;
  
  CameraController? get cameraController => _cameraController;
  bool get isProcessing => _isProcessing;
  bool get isCameraInitialized => _simulationMode || (_cameraController != null && _cameraController!.value.isInitialized);
  UXODetection? get currentDetection => _currentDetection;
  
  Future<void> initializeCamera() async {
    if (isCameraInitialized) return;
    
    // Support simulation for Windows/Dev
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      debugPrint('ℹ️ Simulating Vision System for Development');
      _simulationMode = true;
      notifyListeners();
      return;
    }

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Camera initialization error: $e');
    }
  }

  Future<void> stopCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    notifyListeners();
  }
  
  Future<UXODetection> detectUXO({
    required String imagePath,
    bool continuous = false,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Placeholder UXO detection; replace with a trained model when available.
      _currentDetection = UXODetection.none();

      if (imagePath.isNotEmpty) {
        final result = await _gemmaCore.infer(
          prompt: '''
          Analyze this image for unexploded ordnance (UXO).
          Identify the most likely UXO type and risk level.
          ''',
          images: [imagePath],
          temperature: 0.2,
          maxTokens: 256,
        );

        Map<String, dynamic> dbInfo = {};
        try {
          dbInfo = jsonDecode(result['output']);
        } catch (e) {
          dbInfo = await _uxoDb.getUXOInfo(result['output']);
        }

        _currentDetection = UXODetection(
          detected: dbInfo['detected'] ?? dbInfo.isNotEmpty,
          type: dbInfo['type'] ?? 'Unknown',
          confidence: 0.0,
          riskLevel: dbInfo['riskLevel'] ?? 'LOW',
          safeDistance: dbInfo['safe_distance'] is double
              ? dbInfo['safe_distance'] as double
              : (dbInfo['safe_distance'] is int ? (dbInfo['safe_distance'] as int).toDouble() : 0.0),
          recommendations: List<String>.from(dbInfo['recommendations'] ?? []),
          timestamp: DateTime.now(),
        );
      }

      return _currentDetection!;
    } catch (e) {
      debugPrint('❌ UXO detection error: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  Future<void> broadcastDangerZone(UXODetection detection) async {
    // Broadcast to mesh network
    // Implementation in mesh agent
  }
  
  bool get isInitialized => _cameraController != null && _cameraController!.value.isInitialized;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

final uxoRecognitionAgentProvider = ChangeNotifierProvider((ref) {
  return UXORecognitionAgent();
});