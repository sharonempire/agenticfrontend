import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../error/app_exception.dart';
import '../storage/token_storage.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));
const _uuid = Uuid();

class FastApiClient {
  FastApiClient({required this.tokenStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: '${AppConfig.fastapiBaseUrl}${AppConfig.fastapiPrefix}',
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.requestTimeoutMs),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.addAll([
      _AuthInterceptor(tokenStorage),
      _RequestIdInterceptor(),
      _LoggingInterceptor(),
      _RetryInterceptor(dio: _dio, maxRetries: AppConfig.maxRetries),
    ]);
  }

  final TokenStorage tokenStorage;
  late final Dio _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _wrap(() => _dio.get<T>(path, queryParameters: queryParameters));

  Future<Response<T>> post<T>(String path, {Object? data, Map<String, dynamic>? queryParameters}) =>
      _wrap(() => _dio.post<T>(path, data: data, queryParameters: queryParameters));

  Future<Response<T>> delete<T>(String path) =>
      _wrap(() => _dio.delete<T>(path));

  Future<Response<T>> _wrap<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    final requestId = e.requestOptions.headers['X-Request-Id'] as String? ?? '';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('Network error: ${e.message}', requestId: requestId);
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final body = e.response?.data;
        final detail = body is Map ? body['detail'] ?? body['message'] : '$body';
        return ApiException('$detail', statusCode: status, requestId: requestId);
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      case DioExceptionType.badCertificate:
        return const NetworkException('Bad certificate');
      case DioExceptionType.unknown:
        return NetworkException('Unknown error: ${e.message}', requestId: requestId);
    }
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStorage);
  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Request-Id'] = _uuid.v4();
    handler.next(options);
  }
}

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

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({required this.dio, required this.maxRetries});
  final Dio dio;
  final int maxRetries;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;
    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode ?? 0) >= 500;
    if (isRetryable && attempt < maxRetries) {
      await Future.delayed(Duration(seconds: (attempt + 1)));
      err.requestOptions.extra['_retryCount'] = attempt + 1;
      try {
        handler.resolve(await dio.fetch(err.requestOptions));
        return;
      } on DioException catch (e) {
        handler.next(e);
        return;
      }
    }
    handler.next(err);
  }
}
