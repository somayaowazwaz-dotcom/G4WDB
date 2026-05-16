import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceService extends ChangeNotifier {
  static final VoiceService instance = VoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _isTtsInitialized = false;
  bool _isSttAvailable = false;
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get isSttAvailable => _isSttAvailable;

  VoiceService._internal();

  Future<void> initialize() async {
    await _initTts();
    await _initStt();
  }

  Future<void> _initTts() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await _tts.setLanguage("en-US");
        await _tts.setSpeechRate(0.5);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
        
        _tts.setErrorHandler((msg) {
          debugPrint("TTS Error: $msg");
        });
        
        _isTtsInitialized = true;
      }
    } catch (e) {
      debugPrint("Failed to initialize TTS: $e");
    }
  }

  Future<void> _initStt() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        _isSttAvailable = await _stt.initialize(
          onStatus: (status) {
            debugPrint("STT Status: $status");
            if (status == 'done' || status == 'notListening') {
              _isListening = false;
              notifyListeners();
            }
          },
          onError: (errorNotification) {
            debugPrint("STT Error: ${errorNotification.errorMsg}");
            _isListening = false;
            notifyListeners();
          },
        );
      }
    } catch (e) {
      debugPrint("Failed to initialize STT: $e");
    }
    notifyListeners();
  }

  Future<void> speak(String text, {String? languageCode}) async {
    if (!_isTtsInitialized) return;
    if (languageCode != null) {
      await _tts.setLanguage(languageCode);
    }
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<void> startListening({
    required Function(String words) onResult,
    String? languageCode,
  }) async {
    if (!_isSttAvailable || _isListening) return;

    _isListening = true;
    _lastWords = '';
    notifyListeners();

    await _stt.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        if (result.finalResult) {
          onResult(_lastWords);
          _isListening = false;
          notifyListeners();
        }
      },
      localeId: languageCode,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      onDevice: true, // Force offline recognition if available
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _stt.stop();
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }
}

final voiceServiceProvider = ChangeNotifierProvider<VoiceService>((ref) {
  return VoiceService.instance;
});
