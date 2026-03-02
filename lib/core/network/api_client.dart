import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../error/dio_error_mapper.dart';
import '../error/failure.dart';
import '../utils/auth_session.dart';
import '../utils/token_storage.dart';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required AuthSession authSession,
    Dio? dio,
  }) : _tokenStorage = tokenStorage,
       _authSession = authSession,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: AppConstants.baseUrl,
               connectTimeout: AppConstants.connectTimeout,
               receiveTimeout: AppConstants.receiveTimeout,
               headers: const {
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clearToken();
            _authSession.requestLogout();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final AuthSession _authSession;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}

extension ApiClientX on ApiClient {
  static Failure asFailure(Object error) {
    if (error is Failure) {
      return error;
    }
    return UnknownFailure(error.toString());
  }
}
