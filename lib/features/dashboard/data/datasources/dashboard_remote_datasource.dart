import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_item_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<DashboardItemModel>> fetchItems();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<DashboardItemModel>> fetchItems() async {
    final endpoints = [ApiEndpoints.dashboardItems, ApiEndpoints.dashboard];

    Failure? lastFailure;

    for (final endpoint in endpoints) {
      try {
        final response = await _apiClient.get<dynamic>(endpoint);
        final items = _parseItems(response.data);
        return items;
      } on UnauthorizedFailure {
        rethrow;
      } on Failure catch (failure) {
        lastFailure = failure;
        final isNotFound = failure is ApiFailure && failure.statusCode == 404;
        if (isNotFound) {
          continue;
        }
        rethrow;
      } catch (e) {
        lastFailure = UnknownFailure('Failed to fetch dashboard: $e');
      }
    }

    if (lastFailure != null) {
      throw lastFailure;
    }
    throw const ServerFailure('Unable to fetch dashboard data.');
  }

  List<DashboardItemModel> _parseItems(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) =>
                DashboardItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidates = [map['items'], map['results'], map['data']];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map(
                (item) => DashboardItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      }

      // Some APIs return a single dashboard object.
      return [DashboardItemModel.fromJson(map)];
    }

    throw const ServerFailure('Invalid dashboard response format.');
  }
}
