import 'user.dart';

class AuthSessionEntity {
  const AuthSessionEntity({required this.token, this.user});

  final String token;
  final User? user;
}
