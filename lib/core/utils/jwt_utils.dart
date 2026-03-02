import 'dart:convert';

Map<String, dynamic>? decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    return null;
  }
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return null;
  } catch (_) {
    return null;
  }
}

String? claimAsString(Map<String, dynamic>? payload, List<String> keys) {
  if (payload == null) {
    return null;
  }
  for (final key in keys) {
    final value = payload[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is num) {
      return value.toString();
    }
  }
  return null;
}
