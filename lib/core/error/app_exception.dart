/// Base exception for all app-level errors.
/// Typed so compat repos can decide whether to fallback or propagate.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.requestId});

  final String message;
  final int? statusCode;
  final String? requestId;

  @override
  String toString() => '$runtimeType($message, status=$statusCode)';
}

/// FastAPI returned an error response.
class ApiException extends AppException {
  const ApiException(
    super.message, {
    super.statusCode,
    super.requestId,
    this.errorCode,
  });

  final String? errorCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => (statusCode ?? 0) >= 500;
}

/// Network-level failure (timeout, no connectivity, DNS).
class NetworkException extends AppException {
  const NetworkException(super.message, {super.requestId});
}

/// Supabase-specific error.
class SupabaseException extends AppException {
  const SupabaseException(super.message, {super.statusCode});
}

/// JSON parsing / model mapping failure.
class ParseException extends AppException {
  const ParseException(super.message, {super.requestId});
}

/// Feature not yet implemented on the backend.
class NotImplementedException extends AppException {
  const NotImplementedException(super.message);
}
