import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SilentModeAgent extends ChangeNotifier {
  bool _isSilentMode = false;
  bool _hapticEnabled = false;
  double _systemVolume = 1.0;
  
  bool get isSilentMode => _isSilentMode;
  bool get hapticEnabled => _hapticEnabled;
  bool get isReady => true; // Controller is always instantiated
  
  Future<void> toggleSilentMode() async {
    _isSilentMode = !_isSilentMode;
    
    if (_isSilentMode) {
      await _enableSilentMode();
    } else {
      await _disableSilentMode();
    }
    
    notifyListeners();
  }
  
  Future<void> _enableSilentMode() async {
    // Disable system volume
    await _setSystemVolume(0.0);
    
    // Enable haptic feedback
    _hapticEnabled = true;
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('silent_mode', true);
    
    // Haptic confirmation
    await _silentModeHapticPattern();
    
    debugPrint('🔇 Silent Mode activated');
  }
  
  Future<void> _disableSilentMode() async {
    // Restore system volume
    await _setSystemVolume(_systemVolume);
    
    // Disable haptic feedback
    _hapticEnabled = false;
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('silent_mode', false);
    
    debugPrint('🔊 Silent Mode deactivated');
  }
  
  Future<void> _setSystemVolume(double volume) async {
    // This would require platform-specific implementation
    // For now, just store the value
    _systemVolume = volume;
  }
  
  Future<void> _silentModeHapticPattern() async {
    if (await Vibration.hasVibrator()) {
      // Double pulse pattern
      await Vibration.vibrate(
        pattern: [0, 100, 200, 100],
        intensities: [0, 128, 0, 128],
      );
    }
  }
  
  Future<void> hapticNotification(HapticType type) async {
    if (!_hapticEnabled) return;
    
    switch (type) {
      case HapticType.alert:
        await Vibration.vibrate(duration: 200);
        break;
      case HapticType.success:
        await Vibration.vibrate(pattern: [0, 50, 100, 50]);
        break;
      case HapticType.warning:
        await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 100]);
        break;
      case HapticType.selection:
        await Vibration.vibrate(duration: 50);
        break;
    }
  }
  
  Future<void> activateCovertMode() async {
    // Additional covert features
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [], // Hide all system UI
    );
    
    await toggleSilentMode();
    
    debugPrint('🕵️ Covert Mode activated');
  }
}

enum HapticType {
  alert,
  success,
  warning,
  selection,
}

final silentModeAgentProvider = ChangeNotifierProvider((ref) {
  return SilentModeAgent();
});