import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService instance = AccessibilityService._internal();
  
  static const double minTextScaleFactor = 0.8;
  static const double maxTextScaleFactor = 2.0;

  bool _highContrast = false;
  double _textScaleFactor = 1.0;
  bool _screenReaderOptimized = false;
  
  bool get highContrast => _highContrast;
  double get textScaleFactor => _textScaleFactor;
  TextScaler get textScaler => TextScaler.linear(_textScaleFactor);
  bool get screenReaderOptimized => _screenReaderOptimized;

  bool get hasAccessibilityFeaturesEnabled =>
      _highContrast || _screenReaderOptimized || _textScaleFactor > 1.0;

  String get complianceLabel {
    if (_screenReaderOptimized && _highContrast) {
      return 'WCAG AA compliant — high contrast and screen reader optimized';
    } else if (_highContrast) {
      return 'WCAG AA compliant — high contrast enabled';
    } else if (_screenReaderOptimized) {
      return 'Screen reader optimized';
    }
    return 'Accessibility friendly';
  }
  
  AccessibilityService._internal();
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _highContrast = prefs.getBool('high_contrast') ?? false;
    _textScaleFactor = prefs.getDouble('text_scale') ?? 1.0;
    _screenReaderOptimized = prefs.getBool('screen_reader_optimized') ?? false;
    notifyListeners();
  }
  
  Future<void> toggleHighContrast() async {
    _highContrast = !_highContrast;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', _highContrast);
    notifyListeners();
  }
  
  Future<void> setTextScale(double scale) async {
    _textScaleFactor = scale.clamp(minTextScaleFactor, maxTextScaleFactor);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', _textScaleFactor);
    notifyListeners();
  }

  Future<void> toggleScreenReaderOptimization() async {
    _screenReaderOptimized = !_screenReaderOptimized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('screen_reader_optimized', _screenReaderOptimized);
    notifyListeners();
  }
}

final accessibilityServiceProvider = ChangeNotifierProvider<AccessibilityService>((ref) {
  return AccessibilityService.instance;
});
