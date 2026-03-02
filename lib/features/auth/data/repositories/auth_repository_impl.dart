import '../../../../core/error/failure.dart';
import '../../../../core/utils/token_storage.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSessionEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _tokenStorage.saveToken(session.token);
      return session;
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Login failed: $e');
    }
  }

  @override
  Future<AuthSessionEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      await _tokenStorage.saveToken(session.token);
      return session;
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Registration failed: $e');
    }
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    final token = await _tokenStorage.getToken();
    if (token == null) {
      return null;
    }
    return AuthSessionModel.fromToken(token);
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }
}
