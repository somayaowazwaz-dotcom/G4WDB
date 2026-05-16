import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gemma_engine/gemma_core.dart';
import '../../core/database/tccc_database.dart';

import 'models/triage_result.dart';

class MedicalTriageAgent extends ChangeNotifier {
  final GemmaCore _gemmaCore = GemmaCore.instance;
  final TCCCDatabase _tcccDb = TCCCDatabase();
  TriageResult? _currentResult;
  bool _isProcessing = false;
  
  TriageResult? get currentResult => _currentResult;
  bool get isProcessing => _isProcessing;
  
  Future<TriageResult> assessPatient({
    required String symptoms,
    String? voiceInput,
    List<String>? images,
  }) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      // Combine inputs
      final prompt = _buildTriagePrompt(symptoms, voiceInput);
      
      // Run AI inference
      final result = await _gemmaCore.infer(
        prompt: prompt,
        images: images,
        temperature: 0.3, // Lower temperature for medical accuracy
        maxTokens: 1024,
      );
      
      // Parse AI output
      _currentResult = _parseTriageResult(result['output']);
      
      // Query local TCCC database for validation
      final dbGuidelines = await _tcccDb.getTriageGuidelines();
      _currentResult = _currentResult!.copyWith(
        guidelines: dbGuidelines,
      );
      
      // Haptic feedback based on priority
      await _provideHapticFeedback(_currentResult!.priority);
      
      return _currentResult!;
      
    } catch (e) {
      debugPrint('❌ Medical triage error: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  String _buildTriagePrompt(String symptoms, String? voiceInput) {
    return '''
    You are a medical triage AI assistant following TCCC (Tactical Combat Casualty Care) guidelines.
    
    Patient Symptoms: $symptoms
    Voice Description: ${voiceInput ?? 'N/A'}
    
    Provide:
    1. Triage Category (Immediate/Delayed/Minimal/Expectant)
    2. Priority Level (RED/YELLOW/GREEN/BLACK)
    3. Immediate Actions Required
    4. Treatment Steps
    5. Safety Considerations
    
    Format as JSON.
    ''';
  }
  
  TriageResult _parseTriageResult(String aiOutput) {
    try {
      final data = jsonDecode(aiOutput);
      return TriageResult(
        category: data['category'] ?? 'Delayed',
        priority: data['priority'] ?? 'YELLOW',
        actions: List<String>.from(data['actions'] ?? []),
        treatments: List<String>.from(data['treatments'] ?? []),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('⚠️ Falling back to default triage parsing');
      return TriageResult(
        category: 'Immediate',
        priority: 'RED',
        actions: ['Apply tourniquet', 'Secure airway'],
        treatments: ['Hemorrhage control', 'Airway management'],
        timestamp: DateTime.now(),
      );
    }
  }
  
  Future<void> _provideHapticFeedback(String severity) async {
    switch (severity) {
      case 'RED':
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        break;
      case 'YELLOW':
        await HapticFeedback.mediumImpact();
        break;
      case 'GREEN':
        await HapticFeedback.lightImpact();
        break;
    }
  }
  
  Future<void> provideTreatmentStep(int stepIndex) async {
    // Provide haptic confirmation for each treatment step
    await HapticFeedback.selectionClick();
  }
}

// Provider
final medicalTriageAgentProvider = ChangeNotifierProvider((ref) {
  return MedicalTriageAgent();
});