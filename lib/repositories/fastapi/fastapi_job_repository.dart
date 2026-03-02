import '../../core/error/app_exception.dart';
import '../../core/network/fastapi_client.dart';
import '../../models/common/paginated_response.dart';
import '../../models/job/job.dart';
import '../job_repository.dart';

/// FastAPI-backed job repository.
/// Maps /api/v1/jobs/* and /api/v1/saved-items/jobs to [JobRepository] contract.
class FastApiJobRepository implements JobRepository {
  FastApiJobRepository({required this.client});

  final FastApiClient client;

  @override
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter) async {
    final response = await client.get<Map<String, dynamic>>(
      '/jobs/',
      queryParameters: filter.toQueryParams(),
    );
    return _parsePaginatedJobs(response.data!, filter.page, filter.pageSize);
  }

  @override
  Future<Job> getJobById(String id) async {
    final response = await client.get<Map<String, dynamic>>('/jobs/$id');
    final data = response.data;
    if (data == null) {
      throw const ApiException('Job not found', statusCode: 404);
    }
    return Job.fromJson(data);
  }

  @override
  Future<PaginatedResponse<Job>> searchJobs(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    // Use the dedicated search endpoint or filter via jobs list.
    final response = await client.get<Map<String, dynamic>>(
      '/jobs/',
      queryParameters: {'q': query, 'page': page, 'page_size': pageSize},
    );
    return _parsePaginatedJobs(response.data!, page, pageSize);
  }

  @override
  Future<List<Job>> getSavedJobs() async {
    final response = await client.get<dynamic>('/saved-items/jobs');
    final data = response.data;
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .map((j) => j.copyWith(isSaved: true))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? data['results'] as List? ?? [];
      return items
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .map((j) => j.copyWith(isSaved: true))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Job>> getAppliedJobs() async {
    final response = await client.get<dynamic>('/jobs/applied');
    final data = response.data;
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .map((j) => j.copyWith(isApplied: true))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] as List? ?? data['results'] as List? ?? [];
      return items
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .map((j) => j.copyWith(isApplied: true))
          .toList();
    }
    return [];
  }

  @override
  Future<void> saveJob(String jobId) async {
    await client.post<dynamic>('/saved-items/jobs', data: {'job_id': jobId});
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    await client.delete<dynamic>('/saved-items/jobs/$jobId');
  }

  PaginatedResponse<Job> _parsePaginatedJobs(
    Map<String, dynamic> data,
    int fallbackPage,
    int fallbackPageSize,
  ) {
    if (data.containsKey('items')) {
      return PaginatedResponse.fromJson(data, Job.fromJson);
    }
    if (data.containsKey('results')) {
      final items = (data['results'] as List)
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList();
      return PaginatedResponse<Job>(
        items: items,
        total: data['total'] as int? ?? data['count'] as int? ?? items.length,
        page: data['page'] as int? ?? fallbackPage,
        pageSize: data['page_size'] as int? ?? fallbackPageSize,
      );
    }
    if (data.containsKey('data') && data['data'] is List) {
      final items = (data['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList();
      return PaginatedResponse<Job>(
        items: items,
        total: data['total'] as int? ?? items.length,
        page: fallbackPage,
        pageSize: fallbackPageSize,
      );
    }
    throw const ParseException('Unable to parse jobs response');
  }
}
