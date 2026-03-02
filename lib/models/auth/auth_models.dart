/// Backend auth token pair (separate from Supabase session).
class BackendTokens {
  const BackendTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String tokenType;

  factory BackendTokens.fromJson(Map<String, dynamic> json) {
    return BackendTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }
}

/// User profile as returned by the FastAPI backend.
class BackendProfile {
  const BackendProfile({
    required this.id,
    this.email,
    this.name,
    this.role,
    this.metadata = const {},
  });

  final String id;
  final String? email;
  final String? name;
  final String? role;
  final Map<String, dynamic> metadata;

  factory BackendProfile.fromJson(Map<String, dynamic> json) {
    return BackendProfile(
      id: '${json['id'] ?? json['user_id'] ?? ''}',
      email: json['email'] as String?,
      name: json['name'] as String? ?? json['full_name'] as String?,
      role: json['role'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
