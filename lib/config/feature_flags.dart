import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime feature flags loaded from .env.
/// Toggle individual modules between Supabase and FastAPI independently.
class FeatureFlags {
  FeatureFlags._();

  static bool get courseFinderFastApi =>
      _flag('FF_COURSE_FINDER_FASTAPI');

  static bool get jobFinderFastApi =>
      _flag('FF_JOB_FINDER_FASTAPI');

  static bool get searchFastApi =>
      _flag('FF_SEARCH_FASTAPI');

  static bool get aiCopilot =>
      _flag('FF_AI_COPILOT');

  static bool get webSocket =>
      _flag('FF_WEBSOCKET');

  static bool _flag(String key) =>
      dotenv.env[key]?.toLowerCase() == 'true';
}
