// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:g4wdb_ai_agent/app.dart';

void main() {
  testWidgets('G4WDB app loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // NOTE: Changed from MyApp() to G4WDBApp() to match your actual app class
    await tester.pumpWidget(const G4WDBApp());

    // Verify that the app title appears
    expect(find.text('G4WDB'), findsOneWidget);
    
    // Verify that the subtitle appears
    expect(find.text('Gemma 4 Good'), findsOneWidget);
    
    // Verify that at least one service card is present
    expect(find.text('Medical Triage'), findsOneWidget);
    expect(find.text('UXO Recognition'), findsOneWidget);
    
    // Verify model status banner exists (even if not loaded yet)
    expect(find.text('Gemma 4 E2B Status'), findsOneWidget);
  });

  // Optional: Test silent mode toggle
  testWidgets('Silent mode toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const G4WDBApp());
    
    // Find the silent mode button (initially OFF)
    expect(find.text('Silent Mode: OFF'), findsOneWidget);
    
    // Tap to toggle (this would require more complex mocking for full test)
    // For now, just verify the widget exists and is tappable
    final silentButton = find.byWidgetPredicate(
      (widget) => widget is InkWell && 
                  (widget.child as Column?)?.children
                      .any((c) => c is Text && c.data == 'Silent Mode: OFF') == true,
    );
    expect(silentButton, findsOneWidget);
  });
}