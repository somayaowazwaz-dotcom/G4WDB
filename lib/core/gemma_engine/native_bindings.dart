import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class NativeBindings {
  static GpuDelegateV2? _gpuDelegate;
  
  static Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _initializeGpuDelegate();
    }
  }
  
  static Future<void> _initializeGpuDelegate() async {
    try {
      _gpuDelegate = GpuDelegateV2();
      debugPrint('✅ GPU Delegate initialized');
    } catch (e) {
      debugPrint('⚠️ GPU Delegate not available: $e');
      _gpuDelegate = null;
    }
  }
  
  static Future<String> runInference({
    required String prompt,
    required double temperature,
    required int maxTokens,
  }) async {
    // Native inference call
    // This would call into the native C/C++ code when available.
    final result = await _runNativeInference(
      prompt,
      temperature,
      maxTokens,
    );
    
    return result;
  }
  
  static Future<String> _runNativeInference(
    String prompt,
    double temperature,
    int maxTokens,
  ) async {
    // Simulated native call - replace with actual FFI bindings.
    await Future.delayed(const Duration(milliseconds: 87)); // Simulate latency

    final userQuestion = _extractLastUserMessage(prompt);
    if (userQuestion.isEmpty) {
      return 'I am ready to help. Please ask me a question about this system or your current task.';
    }

    final lowerCaseQuestion = userQuestion.toLowerCase();

    // Humanitarian Agent Simulation Logic
    if (lowerCaseQuestion.contains('tccc') || lowerCaseQuestion.contains('medical') || lowerCaseQuestion.contains('triage')) {
      return '{"category": "Immediate", "priority": "RED", "actions": ["Apply tourniquet", "Check airway"], "treatments": ["High-flow oxygen", "IV fluid"]}';
    }

    if (lowerCaseQuestion.contains('uxo') || lowerCaseQuestion.contains('mine') || lowerCaseQuestion.contains('bomb')) {
      return '{"detected": true, "type": "Anti-Personnel Mine", "riskLevel": "CRITICAL", "safe_distance": 50.0, "recommendations": ["Do not approach", "Mark area", "Report to EOD"]}';
    }

    if (lowerCaseQuestion.contains('where is usa') || lowerCaseQuestion.contains('where is the usa') || lowerCaseQuestion.contains('where is united states') || lowerCaseQuestion.contains('where is united states of america')) {
      return 'The United States of America is located in North America, bordered by Canada to the north and Mexico to the south, with coastlines on the Atlantic and Pacific oceans.';
    }

    if (lowerCaseQuestion.contains('world war ii') || lowerCaseQuestion.contains('world war 2') || lowerCaseQuestion.contains('wwii') || lowerCaseQuestion.contains('war ww2') || lowerCaseQuestion.contains('war ww ii')) {
      return 'World War II was a global conflict fought from 1939 to 1945 between the Allies and the Axis powers. It was one of the largest wars in history and reshaped international politics, borders, and economies.';
    }

    if (lowerCaseQuestion.contains('name')) {
      return 'This system is called G4WDB AI Agent. It provides offline support through Gemma 4 for your mission tasks.';
    }
    if (lowerCaseQuestion.contains('offline')) {
      return 'Yes, I am running in offline mode and can answer your questions without an internet connection.';
    }
    if (lowerCaseQuestion.contains('system')) {
      return 'This is the G4WDB AI Agent. It integrates chat, survival tracking, mesh networking, and mission support offline.';
    }

    final generalAnswer = _answerGeneralQuestion(lowerCaseQuestion, userQuestion);
    if (generalAnswer != null) {
      return generalAnswer;
    }

    return 'Gemma 4 here. You asked: "$userQuestion". I am running offline and ready to assist you.';
  }

  static String? _answerGeneralQuestion(String lowerCaseQuestion, String originalQuestion) {
    if (lowerCaseQuestion.contains('what is') || lowerCaseQuestion.contains('who is') || lowerCaseQuestion.contains('tell me about')) {
      if (lowerCaseQuestion.contains('internet')) {
        return 'The internet is a global network of computers and servers that allows people and devices to communicate and share information.';
      }
      if (lowerCaseQuestion.contains('google')) {
        return 'Google is a technology company best known for its search engine, online advertising services, and software products.';
      }
      if (lowerCaseQuestion.contains('war')) {
        return 'A war is an organized, large-scale conflict between groups such as nations or states. World War II was fought from 1939 to 1945 and involved most of the world’s major powers.';
      }
      if (lowerCaseQuestion.contains('usa') || lowerCaseQuestion.contains('united states')) {
        return 'The United States is a country in North America composed of 50 states and a federal district. It is one of the largest and most populous nations in the world.';
      }
      if (lowerCaseQuestion.contains('gemma')) {
        return 'Gemma is an offline AI assistant used in this app to help answer questions and support mission tasks in the field.';
      }

      return 'I can help with questions about your mission, geography, and offline system status. Please try asking another question.';
    }
    if (lowerCaseQuestion.contains('how are you') || lowerCaseQuestion.contains('how do you do')) {
      return 'I am running offline and ready to assist you. Ask me a question about your mission, systems, or environment.';
    }
    return null;
  }

  static String _extractLastUserMessage(String prompt) {
    final regex = RegExp(r'User:\s*(.+?)(?:\n\nAssistant:|\$)', dotAll: true);
    final matches = regex.allMatches(prompt);
    if (matches.isEmpty) {
      return '';
    }
    return matches.last.group(1)?.trim() ?? '';
  }
  
  static Future<void> dispose() async {
    _gpuDelegate?.delete();
  }
}