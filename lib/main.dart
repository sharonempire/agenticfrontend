import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler — catches uncaught async errors.
  FlutterError.onError = (details) {
    _log.e('FlutterError: ${details.exceptionAsString()}');
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _log.e('Uncaught error: $error\n$stack');
    return true;
  };

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    _log.w('Could not load .env file ($e), using defaults');
  }

  if (_requiresSupabase()) {
    final url = AppConfig.supabaseUrl;
    final key = AppConfig.supabaseAnonKey;
    if (url.isEmpty || key.isEmpty) {
      _log.e('Supabase is required but SUPABASE_URL or SUPABASE_ANON_KEY is empty');
    } else {
      await Supabase.initialize(url: url, anonKey: key);
    }
  }

  await initDependencies();
  runApp(const AgenticApp());
}

bool _requiresSupabase() {
  final mode = AppConfig.backendMode;
  if (mode != BackendMode.fastapiOnly) return true;
  return !AppConfig.courseFinderFastApi ||
      !AppConfig.jobFinderFastApi ||
      !AppConfig.searchFastApi;
}

class AgenticApp extends StatelessWidget {
  const AgenticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agentic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: AppRouter.router,
    );
  }
}
