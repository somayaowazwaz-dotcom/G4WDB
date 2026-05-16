import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';

class VoiceInputWidget extends StatefulWidget {
  final Function(String text) onResult;

  const VoiceInputWidget({super.key, required this.onResult});

  @override
  _VoiceInputWidgetState createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _listening = false;
  bool _available = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _speechToText.initialize().then((available) {
        setState(() => _available = available);
      });
    }
  }

  void _startListening() async {
    if (!_available) return;
    await _speechToText.listen(onResult: (result) {
      if (result.finalResult) {
        widget.onResult(result.recognizedWords);
      }
    });
    setState(() => _listening = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) {
      return const IconButton(
        icon: Icon(Icons.mic_off),
        onPressed: null,
        tooltip: 'Voice input not available on this platform',
      );
    }
    return IconButton(
      icon: Icon(_listening ? Icons.mic : Icons.mic_none),
      onPressed: _startListening,
    );
  }
}