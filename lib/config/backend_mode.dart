import 'env_config.dart';

/// Controls which backend to use for data fetching.
enum BackendMode {
  /// Only use Supabase (original behavior).
  supabaseOnly,

  /// Try FastAPI first, fallback to Supabase on failure.
  fastapiPreferred,

  /// Only use FastAPI (no fallback). Errors propagate to UI.
  fastapiOnly,
}

BackendMode resolveBackendMode() {
  switch (EnvConfig.backendModeRaw) {
    case 'fastapi_preferred':
      return BackendMode.fastapiPreferred;
    case 'fastapi_only':
      return BackendMode.fastapiOnly;
    case 'supabase_only':
    default:
      return BackendMode.supabaseOnly;
  }
}
