import 'package:logger/logger.dart';
import '../../core/config/app_config.dart';
import 'app_exception.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

bool shouldFallback(AppException e, BackendMode mode) {
  if (mode != BackendMode.fastapiPreferred) return false;
  if (e is NetworkException) return true;
  if (e is ApiException && e.isUnauthorized) return true;
  if (e is ApiException && e.isNotFound) return true;
  if (e is ApiException && e.isServerError) return true;
  if (e is NotImplementedException) return true;
  if (e is ParseException) return true;
  return false;
}

void logFallback(String module, String method, AppException e) {
  _log.w('[$module.$method] FastAPI failed (${e.message}), falling back to Supabase');
}
