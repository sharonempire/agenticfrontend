class AppConstants {
  AppConstants._();

  static const String appName = 'AI Backend Frontend';

  /// Override with:
  /// flutter run --dart-define=API_BASE_URL=https://your-domain.com/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String tokenStorageKey = 'jwt_token';
}
