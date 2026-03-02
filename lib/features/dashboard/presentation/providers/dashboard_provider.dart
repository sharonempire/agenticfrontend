import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/dashboard_item.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    required DashboardRepository repository,
    required AuthProvider authProvider,
  }) : _repository = repository,
       _authProvider = authProvider;

  final DashboardRepository _repository;
  final AuthProvider _authProvider;

  bool _isLoading = false;
  bool _hasLoaded = false;
  List<DashboardItem> _items = const [];
  Failure? _failure;

  bool get isLoading => _isLoading;
  List<DashboardItem> get items => _items;
  String? get errorMessage => _failure?.message;

  Future<void> fetchItems({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _failure = null;
    notifyListeners();

    try {
      _items = await _repository.fetchItems();
      _hasLoaded = true;
    } on UnauthorizedFailure catch (failure) {
      _failure = failure;
      await _authProvider.handleSessionExpired();
    } on Failure catch (failure) {
      _failure = failure;
    } catch (e) {
      _failure = UnknownFailure('Failed to load dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_failure == null) {
      return;
    }
    _failure = null;
    notifyListeners();
  }
}
