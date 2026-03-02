import '../../../../core/utils/jwt_utils.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id =
        _firstNonEmpty([
          json['id'],
          json['user_id'],
          json['uid'],
          json['sub'],
        ]) ??
        '';
    final email = _firstNonEmpty([json['email'], json['username']]) ?? '';
    final name =
        _firstNonEmpty([
          json['name'],
          json['full_name'],
          json['display_name'],
        ]) ??
        email;

    return UserModel(id: id, email: email, name: name.isEmpty ? 'User' : name);
  }

  factory UserModel.fromToken(
    String token, {
    String? fallbackEmail,
    String? fallbackName,
  }) {
    final payload = decodeJwtPayload(token);
    final id = claimAsString(payload, ['sub', 'user_id', 'id']) ?? '';
    final email =
        claimAsString(payload, ['email', 'username']) ?? (fallbackEmail ?? '');
    final name =
        claimAsString(payload, ['name', 'full_name']) ?? fallbackName ?? 'User';

    return UserModel(id: id, email: email, name: name);
  }

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};

  static String? _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is num) {
        return value.toString();
      }
    }
    return null;
  }
}
