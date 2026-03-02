import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgenticApp());
}

class AgenticApp extends StatelessWidget {
  const AgenticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
