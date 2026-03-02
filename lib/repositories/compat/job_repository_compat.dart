import 'package:logger/logger.dart';

import '../../config/backend_mode.dart';
import '../../config/feature_flags.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/fallback_helper.dart';
import '../../models/common/paginated_response.dart';
import '../../models/job/job.dart';
import '../job_repository.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Compatibility adapter for jobs.
/// Routes calls through FastAPI when enabled, falls back to Supabase.
class JobRepositoryCompat implements JobRepository {
  JobRepositoryCompat({
    required this.fastApi,
    required this.supabase,
    required this.mode,
  });

  final JobRepository fastApi;
  final JobRepository supabase;
  final BackendMode mode;

  BackendMode get _effectiveMode =>
      FeatureFlags.jobFinderFastApi ? mode : BackendMode.supabaseOnly;

  @override
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter) =>
      _tryWithFallback('getJobs', () => fastApi.getJobs(filter), () => supabase.getJobs(filter));

  @override
  Future<Job> getJobById(String id) =>
      _tryWithFallback('getJobById', () => fastApi.getJobById(id), () => supabase.getJobById(id));

  @override
  Future<PaginatedResponse<Job>> searchJobs(String query, {int page = 1, int pageSize = 20}) =>
      _tryWithFallback(
        'searchJobs',
        () => fastApi.searchJobs(query, page: page, pageSize: pageSize),
        () => supabase.searchJobs(query, page: page, pageSize: pageSize),
      );

  @override
  Future<List<Job>> getSavedJobs() =>
      _tryWithFallback('getSavedJobs', () => fastApi.getSavedJobs(), () => supabase.getSavedJobs());

  @override
  Future<List<Job>> getAppliedJobs() =>
      _tryWithFallback('getAppliedJobs', () => fastApi.getAppliedJobs(), () => supabase.getAppliedJobs());

  @override
  Future<void> saveJob(String jobId) =>
      _tryWithFallback('saveJob', () => fastApi.saveJob(jobId), () => supabase.saveJob(jobId));

  @override
  Future<void> unsaveJob(String jobId) =>
      _tryWithFallback('unsaveJob', () => fastApi.unsaveJob(jobId), () => supabase.unsaveJob(jobId));

  Future<T> _tryWithFallback<T>(
    String method,
    Future<T> Function() fastApiCall,
    Future<T> Function() supabaseCall,
  ) async {
    final effective = _effectiveMode;

    if (effective == BackendMode.supabaseOnly) {
      return supabaseCall();
    }

    try {
      return await fastApiCall();
    } on AppException catch (e) {
      if (shouldFallback(e, effective)) {
        logFallback('JobRepo', method, e);
        return supabaseCall();
      }
      rethrow;
    } catch (e) {
      if (effective == BackendMode.fastapiPreferred) {
        _log.w('[JobRepo.$method] Unexpected error ($e), falling back to Supabase');
        return supabaseCall();
      }
      rethrow;
    }
  }
}
