import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../config/env_config.dart';
import '../error/app_exception.dart';
import '../storage/token_storage.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));
const _uuid = Uuid();

/// Single Dio-based HTTP client for the FastAPI backend.
/// Includes auth token injection, request-id correlation, retry, and logging.
class FastApiClient {
  FastApiClient({required this.tokenStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: '${EnvConfig.fastApiBaseUrl}${EnvConfig.fastApiPrefix}',
      connectTimeout: Duration(milliseconds: EnvConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: EnvConfig.requestTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(tokenStorage),
      _RequestIdInterceptor(),
      _LoggingInterceptor(),
      _RetryInterceptor(
        dio: _dio,
        maxRetries: EnvConfig.maxRetries,
        retryDelayMs: EnvConfig.retryDelayMs,
      ),
    ]);
  }

  final TokenStorage tokenStorage;
  late final Dio _dio;

  /// Expose the raw Dio instance for edge cases (WebSocket upgrade etc).
  Dio get dio => _dio;

  // ── Convenience wrappers that map Dio errors → AppException ──

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _wrap(() => _dio.get<T>(path, queryParameters: queryParameters));

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _wrap(() => _dio.post<T>(path, data: data, queryParameters: queryParameters));

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) =>
      _wrap(() => _dio.put<T>(path, data: data));

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
  }) =>
      _wrap(() => _dio.patch<T>(path, data: data));

  Future<Response<T>> delete<T>(String path) =>
      _wrap(() => _dio.delete<T>(path));

  /// Wraps all Dio calls and maps errors to typed [AppException].
  Future<Response<T>> _wrap<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    final requestId =
        e.requestOptions.headers['X-Request-Id'] as String? ?? '';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          'Network error: ${e.message}',
          requestId: requestId,
        );
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final body = e.response?.data;
        final detail = body is Map ? body['detail'] ?? body['message'] : '$body';
        final errorCode = body is Map ? body['error_code'] as String? : null;
        return ApiException(
          '$detail',
          statusCode: status,
          requestId: requestId,
          errorCode: errorCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      case DioExceptionType.badCertificate:
        return const NetworkException('Bad certificate');
      case DioExceptionType.unknown:
        return NetworkException(
          'Unknown error: ${e.message}',
          requestId: requestId,
        );
    }
  }
}

// ── Interceptors ──────────────────────────────────────────────────────────

/// Injects the FastAPI bearer token on every request, if available.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStorage);
  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Adds a unique X-Request-Id header for correlation.
class _RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Request-Id'] = _uuid.v4();
    handler.next(options);
  }
}

/// Logs request/response at debug level.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e('✗ ${err.requestOptions.uri} → ${err.message}');
    handler.next(err);
  }
}

/// Retries idempotent requests on transient failures (5xx, timeout).
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({
    required this.dio,
    required this.maxRetries,
    required this.retryDelayMs,
  });

  final Dio dio;
  final int maxRetries;
  final int retryDelayMs;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;
    final isRetryable = _isRetryable(err);

    if (isRetryable && attempt < maxRetries) {
      _log.w('Retry ${attempt + 1}/$maxRetries for ${err.requestOptions.uri}');
      await Future.delayed(Duration(milliseconds: retryDelayMs * (attempt + 1)));

      err.requestOptions.extra['_retryCount'] = attempt + 1;
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        handler.next(e);
        return;
      }
    }
    handler.next(err);
  }

  bool _isRetryable(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode ?? 0;
    return status >= 500 && status < 600;
  }
}
