import 'package:flutter_dotenv/flutter_dotenv.dart';

enum BackendMode { supabaseOnly, fastapiPreferred, fastapiOnly }

class AppConfig {
  AppConfig._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get fastapiBaseUrl =>
      dotenv.env['FASTAPI_BASE_URL'] ?? 'http://localhost:8000';
  static String get fastapiPrefix =>
      dotenv.env['FASTAPI_API_PREFIX'] ?? '/api/v1';

  static BackendMode get backendMode {
    switch (dotenv.env['BACKEND_MODE']) {
      case 'fastapi_preferred': return BackendMode.fastapiPreferred;
      case 'fastapi_only': return BackendMode.fastapiOnly;
      default: return BackendMode.supabaseOnly;
    }
  }

  static int get requestTimeoutMs =>
      int.tryParse(dotenv.env['REQUEST_TIMEOUT_MS'] ?? '') ?? 15000;
  static int get connectTimeoutMs =>
      int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '') ?? 10000;
  static int get maxRetries =>
      int.tryParse(dotenv.env['MAX_RETRIES'] ?? '') ?? 2;

  static bool flag(String key) =>
      dotenv.env[key]?.toLowerCase() == 'true';

  static bool get courseFinderFastApi => flag('FF_COURSE_FINDER_FASTAPI');
  static bool get jobFinderFastApi => flag('FF_JOB_FINDER_FASTAPI');
  static bool get searchFastApi => flag('FF_SEARCH_FASTAPI');
  static bool get aiCopilot => flag('FF_AI_COPILOT');

  static BackendMode modeFor(String feature) {
    final enabled = flag('FF_${feature}_FASTAPI');
    return enabled ? backendMode : BackendMode.supabaseOnly;
  }
}
