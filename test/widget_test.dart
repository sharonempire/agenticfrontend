import 'package:flutter_test/flutter_test.dart';

import 'package:agenticfrontend/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const AgenticApp());
    expect(find.text('Agentic Frontend'), findsOneWidget);
  });
}
