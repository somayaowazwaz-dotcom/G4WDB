import 'package:flutter/material.dart';

class CovertUI {
  static void hideStatusBar() {
    // Implementation to hide status bar using SystemChrome
  }

  static Widget buildSafeArea(Widget child) {
    return SafeArea(
      child: child,
    );
  }
}