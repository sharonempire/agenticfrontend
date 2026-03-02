import '../../../../core/error/failure.dart';
import '../../domain/entities/dashboard_item.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<List<DashboardItem>> fetchItems() async {
    try {
      return await _remoteDataSource.fetchItems();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Dashboard repository error: $e');
    }
  }
}
