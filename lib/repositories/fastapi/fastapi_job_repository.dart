import '../../core/error/app_exception.dart';
import '../../core/network/fastapi_client.dart';
import '../../models/common/paginated_response.dart';
import '../../models/job/job.dart';
import '../interfaces/job_repository.dart';

class FastApiJobRepository implements JobRepository {
  FastApiJobRepository({required this.client});
  final FastApiClient client;

  @override
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter) async {
    final response = await client.get<Map<String, dynamic>>('/jobs/', queryParameters: filter.toQueryParams());
    final data = response.data;
    if (data == null) return PaginatedResponse<Job>(items: [], total: 0, page: filter.page, pageSize: filter.pageSize);
    return PaginatedResponse.fromJson(data, Job.fromJson);
  }

  @override
  Future<Job> getJobById(String id) async {
    if (id.contains('/') || id.contains('..')) throw const ApiException('Invalid job ID', statusCode: 400);
    final response = await client.get<Map<String, dynamic>>('/jobs/$id');
    if (response.data == null) throw const ApiException('Job not found', statusCode: 404);
    return Job.fromJson(response.data!);
  }

  @override
  Future<List<Job>> getSavedJobs() async {
    final response = await client.get<dynamic>('/saved-items/jobs');
    return _parseJobList(response.data, isSaved: true);
  }

  @override
  Future<List<Job>> getAppliedJobs() async {
    final response = await client.get<dynamic>('/jobs/applied');
    return _parseJobList(response.data, isApplied: true);
  }

  @override
  Future<void> saveJob(String jobId) async => client.post<dynamic>('/saved-items/jobs', data: {'job_id': jobId});

  @override
  Future<void> unsaveJob(String jobId) async {
    if (jobId.contains('/') || jobId.contains('..')) throw const ApiException('Invalid job ID', statusCode: 400);
    await client.delete<dynamic>('/saved-items/jobs/$jobId');
  }

  List<Job> _parseJobList(dynamic data, {bool isSaved = false, bool isApplied = false}) {
    List<dynamic> raw;
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      raw = data['items'] as List? ?? [];
    } else {
      return [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Job.fromJson)
        .map((j) => j.copyWith(isSaved: isSaved ? true : null, isApplied: isApplied ? true : null))
        .toList();
  }
}
