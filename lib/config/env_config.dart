import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
/// All values sourced from .env — never hardcode secrets.
class EnvConfig {
  EnvConfig._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get fastApiBaseUrl =>
      dotenv.env['FASTAPI_BASE_URL'] ?? 'http://localhost:8000';
  static String get fastApiPrefix =>
      dotenv.env['FASTAPI_API_PREFIX'] ?? '/api/v1';

  static String get backendModeRaw =>
      dotenv.env['BACKEND_MODE'] ?? 'supabase_only';

  static int get requestTimeoutMs =>
      int.tryParse(dotenv.env['REQUEST_TIMEOUT_MS'] ?? '') ?? 15000;
  static int get connectTimeoutMs =>
      int.tryParse(dotenv.env['CONNECT_TIMEOUT_MS'] ?? '') ?? 10000;

  static int get maxRetries =>
      int.tryParse(dotenv.env['MAX_RETRIES'] ?? '') ?? 2;
  static int get retryDelayMs =>
      int.tryParse(dotenv.env['RETRY_DELAY_MS'] ?? '') ?? 1000;
}
