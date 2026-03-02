import 'package:logger/logger.dart';
import '../../core/config/app_config.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/fallback_helper.dart';
import '../../models/common/paginated_response.dart';
import '../../models/job/job.dart';
import '../interfaces/job_repository.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

class JobRepositoryCompat implements JobRepository {
  JobRepositoryCompat({required this.fastApi, required this.supabase});
  final JobRepository fastApi;
  final JobRepository supabase;

  BackendMode get _mode => AppConfig.jobFinderFastApi ? AppConfig.backendMode : BackendMode.supabaseOnly;

  @override Future<PaginatedResponse<Job>> getJobs(JobFilter f) => _try('getJobs', () => fastApi.getJobs(f), () => supabase.getJobs(f));
  @override Future<Job> getJobById(String id) => _try('getJobById', () => fastApi.getJobById(id), () => supabase.getJobById(id));
  @override Future<List<Job>> getSavedJobs() => _try('getSavedJobs', () => fastApi.getSavedJobs(), () => supabase.getSavedJobs());
  @override Future<List<Job>> getAppliedJobs() => _try('getAppliedJobs', () => fastApi.getAppliedJobs(), () => supabase.getAppliedJobs());
  @override Future<void> saveJob(String id) => _try('saveJob', () => fastApi.saveJob(id), () => supabase.saveJob(id));
  @override Future<void> unsaveJob(String id) => _try('unsaveJob', () => fastApi.unsaveJob(id), () => supabase.unsaveJob(id));

  Future<T> _try<T>(String m, Future<T> Function() fast, Future<T> Function() supa) async {
    if (_mode == BackendMode.supabaseOnly) return supa();
    try { return await fast(); }
    on AppException catch (e) { if (shouldFallback(e, _mode)) { logFallback('JobRepo', m, e); return supa(); } rethrow; }
    catch (e) { if (_mode == BackendMode.fastapiPreferred) { _log.w('[JobRepo.$m] Unexpected ($e)'); return supa(); } rethrow; }
  }
}
