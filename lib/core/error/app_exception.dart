sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.requestId});
  final String message;
  final int? statusCode;
  final String? requestId;

  @override
  String toString() => '$runtimeType($message, status=$statusCode)';
}

class ApiException extends AppException {
  const ApiException(super.message, {super.statusCode, super.requestId, this.errorCode});
  final String? errorCode;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => (statusCode ?? 0) >= 500;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.requestId});
}

class SupabaseException extends AppException {
  const SupabaseException(super.message, {super.statusCode});
}

class ParseException extends AppException {
  const ParseException(super.message, {super.requestId});
}

class NotImplementedException extends AppException {
  const NotImplementedException(super.message);
}
