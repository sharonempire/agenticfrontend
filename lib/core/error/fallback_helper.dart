import 'package:logger/logger.dart';

import '../../config/backend_mode.dart';
import 'app_exception.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Determines whether a given exception should trigger a Supabase fallback.
bool shouldFallback(AppException e, BackendMode mode) {
  if (mode == BackendMode.fastapiOnly) return false;
  if (mode == BackendMode.supabaseOnly) return false; // never reaches FastAPI

  // In fastapiPreferred, fallback on these conditions:
  if (e is NetworkException) return true;
  if (e is ApiException && e.isUnauthorized) return true;
  if (e is ApiException && e.isNotFound) return true;
  if (e is ApiException && e.isServerError) return true;
  if (e is NotImplementedException) return true;
  if (e is ParseException) return true;

  return false;
}

/// Logs a fallback event for observability.
void logFallback(String module, String method, AppException e) {
  _log.w('[$module.$method] FastAPI failed (${e.message}), falling back to Supabase');
}
