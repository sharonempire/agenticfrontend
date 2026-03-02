import '../entities/auth_session_entity.dart';

abstract class AuthRepository {
  Future<AuthSessionEntity> login({
    required String email,
    required String password,
  });

  Future<AuthSessionEntity> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSessionEntity?> restoreSession();

  Future<void> logout();
}
