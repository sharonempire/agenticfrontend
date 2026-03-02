import '../../models/common/paginated_response.dart';
import '../../models/job/job.dart';

abstract class JobRepository {
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter);
  Future<Job> getJobById(String id);
  Future<List<Job>> getSavedJobs();
  Future<List<Job>> getAppliedJobs();
  Future<void> saveJob(String jobId);
  Future<void> unsaveJob(String jobId);
}
