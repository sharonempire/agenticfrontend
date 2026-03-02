import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/auth_session.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository repository,
    required AuthSession authSession,
  }) : _repository = repository,
       _authSession = authSession {
    _logoutSubscription = _authSession.onLogoutRequested.listen((_) {
      handleSessionExpired();
    });
    initialize();
  }

  final AuthRepository _repository;
  final AuthSession _authSession;

  StreamSubscription<void>? _logoutSubscription;

  bool _isInitialized = false;
  bool _isSubmitting = false;
  AuthSessionEntity? _session;
  Failure? _failure;

  bool get isInitialized => _isInitialized;
  bool get isSubmitting => _isSubmitting;
  bool get isAuthenticated => _session != null;
  AuthSessionEntity? get session => _session;
  String? get errorMessage => _failure?.message;

  Future<void> initialize() async {
    _isInitialized = false;
    notifyListeners();
    try {
      _session = await _repository.restoreSession();
      _failure = null;
    } on Failure catch (failure) {
      _session = null;
      _failure = failure;
    } catch (e) {
      _session = null;
      _failure = UnknownFailure('Failed to restore session: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isSubmitting = true;
    _failure = null;
    notifyListeners();

    try {
      _session = await _repository.login(email: email, password: password);
      return true;
    } on Failure catch (failure) {
      _session = null;
      _failure = failure;
      return false;
    } catch (e) {
      _session = null;
      _failure = UnknownFailure('Login error: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isSubmitting = true;
    _failure = null;
    notifyListeners();

    try {
      _session = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      return true;
    } on Failure catch (failure) {
      _session = null;
      _failure = failure;
      return false;
    } catch (e) {
      _session = null;
      _failure = UnknownFailure('Registration error: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.logout();
      _session = null;
      _failure = null;
    } on Failure catch (failure) {
      _failure = failure;
    } catch (e) {
      _failure = UnknownFailure('Logout failed: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> handleSessionExpired() async {
    _session = null;
    _failure = const UnauthorizedFailure();
    notifyListeners();
  }

  void clearError() {
    if (_failure == null) {
      return;
    }
    _failure = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _logoutSubscription?.cancel();
    super.dispose();
  }
}
