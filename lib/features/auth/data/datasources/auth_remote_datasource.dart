import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final map = _asMap(response.data);
    return AuthSessionModel.fromJson(map, fallbackEmail: email);
  }

  @override
  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    final map = _asMap(response.data);
    return AuthSessionModel.fromJson(
      map,
      fallbackEmail: email,
      fallbackName: name,
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const ServerFailure('Invalid response format from auth endpoint.');
  }
}
