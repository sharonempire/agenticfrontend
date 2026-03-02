import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages secure storage for backend JWT tokens.
/// Supabase tokens are managed by supabase_flutter internally —
/// this handles the separate FastAPI backend token.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'fastapi_access_token';
  static const _keyRefreshToken = 'fastapi_refresh_token';

  Future<String?> get accessToken => _storage.read(key: _keyAccessToken);
  Future<String?> get refreshToken => _storage.read(key: _keyRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  Future<bool> get hasToken async => (await accessToken) != null;
}
