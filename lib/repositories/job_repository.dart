import '../models/common/paginated_response.dart';
import '../models/job/job.dart';

/// Abstract contract for job data access.
abstract class JobRepository {
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter);
  Future<Job> getJobById(String id);
  Future<PaginatedResponse<Job>> searchJobs(String query, {int page = 1, int pageSize = 20});
  Future<List<Job>> getSavedJobs();
  Future<List<Job>> getAppliedJobs();
  Future<void> saveJob(String jobId);
  Future<void> unsaveJob(String jobId);
}
