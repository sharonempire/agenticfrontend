import 'dart:async';

class AuthSession {
  final StreamController<void> _logoutController =
      StreamController<void>.broadcast();

  Stream<void> get onLogoutRequested => _logoutController.stream;

  void requestLogout() {
    if (!_logoutController.isClosed) {
      _logoutController.add(null);
    }
  }

  void dispose() {
    _logoutController.close();
  }
}
