import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class TokenStorage {
  const TokenStorage();

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenStorageKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenStorageKey);
    if (token == null || token.trim().isEmpty) {
      return null;
    }
    return token;
  }

  Future<bool> hasToken() async => (await getToken()) != null;

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenStorageKey);
  }
}
