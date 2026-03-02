import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  static const _keyAccess = 'fastapi_access_token';
  static const _keyRefresh = 'fastapi_refresh_token';

  Future<String?> get accessToken => _storage.read(key: _keyAccess);
  Future<String?> get refreshToken => _storage.read(key: _keyRefresh);

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _keyAccess, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefresh, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }

  Future<bool> get hasToken async => (await accessToken) != null;
}
