import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const HapticButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      child: child,
    );
  }
}