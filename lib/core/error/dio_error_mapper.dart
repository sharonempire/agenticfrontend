import 'package:dio/dio.dart';

import 'failure.dart';

Failure mapDioException(DioException exception) {
  final statusCode = exception.response?.statusCode;

  if (statusCode == 401) {
    return const UnauthorizedFailure();
  }

  if (statusCode != null) {
    final message =
        _extractMessage(exception.response?.data) ??
        'Request failed with status code $statusCode';

    if (statusCode >= 500) {
      return ServerFailure(message, statusCode: statusCode);
    }

    if (statusCode == 422) {
      return ValidationFailure(message, statusCode: statusCode);
    }

    return ApiFailure(message, statusCode: statusCode);
  }

  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.cancel:
      return const ApiFailure('Request cancelled.');
    case DioExceptionType.badCertificate:
      return const ApiFailure('Invalid server certificate.');
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      return UnknownFailure(exception.message ?? 'Unexpected network error.');
  }
}

String? _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    final error = data['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
  }
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  return null;
}
