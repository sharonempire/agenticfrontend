import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({required super.token, super.user});

  factory AuthSessionModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackEmail,
    String? fallbackName,
  }) {
    final raw = _unwrap(json);
    final token = _extractToken(raw);
    if (token.isEmpty) {
      throw const ServerFailure('JWT token missing in auth response.');
    }

    final user = _extractUser(
      raw,
      token: token,
      fallbackEmail: fallbackEmail,
      fallbackName: fallbackName,
    );

    return AuthSessionModel(token: token, user: user);
  }

  factory AuthSessionModel.fromToken(String token) {
    return AuthSessionModel(token: token, user: UserModel.fromToken(token));
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return json;
  }

  static String _extractToken(Map<String, dynamic> json) {
    final candidates = [
      json['access_token'],
      json['token'],
      json['jwt'],
      json['accessToken'],
    ];
    for (final value in candidates) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  static UserModel _extractUser(
    Map<String, dynamic> json, {
    required String token,
    String? fallbackEmail,
    String? fallbackName,
  }) {
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      return UserModel.fromJson(rawUser);
    }
    if (rawUser is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return UserModel.fromToken(
      token,
      fallbackEmail: fallbackEmail,
      fallbackName: fallbackName,
    );
  }
}
