import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agenticfrontend/main.dart';

void main() {
  testWidgets('AgenticApp creates MaterialApp.router', (WidgetTester tester) async {
    await tester.pumpWidget(const AgenticApp());
    expect(find.byType(AgenticApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    // Drain pending timers (SplashPage has a 2s timer).
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
