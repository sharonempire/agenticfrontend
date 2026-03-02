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
    return PaginatedResponse.fromJson(response.data!, Job.fromJson);
  }

  @override
  Future<Job> getJobById(String id) async {
    final response = await client.get<Map<String, dynamic>>('/jobs/$id');
    if (response.data == null) throw const ApiException('Job not found', statusCode: 404);
    return Job.fromJson(response.data!);
  }

  @override
  Future<List<Job>> getSavedJobs() async {
    final response = await client.get<dynamic>('/saved-items/jobs');
    final data = response.data;
    if (data is List) return data.cast<Map<String, dynamic>>().map(Job.fromJson).map((j) => j.copyWith(isSaved: true)).toList();
    if (data is Map<String, dynamic>) { final items = data['items'] as List? ?? []; return items.cast<Map<String, dynamic>>().map(Job.fromJson).map((j) => j.copyWith(isSaved: true)).toList(); }
    return [];
  }

  @override
  Future<List<Job>> getAppliedJobs() async {
    final response = await client.get<dynamic>('/jobs/applied');
    final data = response.data;
    if (data is List) return data.cast<Map<String, dynamic>>().map(Job.fromJson).map((j) => j.copyWith(isApplied: true)).toList();
    if (data is Map<String, dynamic>) { final items = data['items'] as List? ?? []; return items.cast<Map<String, dynamic>>().map(Job.fromJson).map((j) => j.copyWith(isApplied: true)).toList(); }
    return [];
  }

  @override
  Future<void> saveJob(String jobId) async => client.post<dynamic>('/saved-items/jobs', data: {'job_id': jobId});

  @override
  Future<void> unsaveJob(String jobId) async => client.delete<dynamic>('/saved-items/jobs/$jobId');
}
