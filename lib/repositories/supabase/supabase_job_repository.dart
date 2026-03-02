import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/app_exception.dart';
import '../../models/common/paginated_response.dart';
import '../../models/job/job.dart';
import '../interfaces/job_repository.dart';

class SupabaseJobRepository implements JobRepository {
  SupabaseJobRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  @override
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter) async {
    try {
      var query = _client.from('jobs').select();
      if (filter.query != null && filter.query!.isNotEmpty) query = query.ilike('title', '%${filter.query}%');
      if (filter.category != null) query = query.eq('category', filter.category!);
      if (filter.type != null) query = query.eq('type', filter.type!);
      if (filter.isRemote == true) query = query.eq('is_remote', true);
      final from = (filter.page - 1) * filter.pageSize;
      final data = await query.range(from, from + filter.pageSize - 1);
      final count = await _client.from('jobs').select('id').count(CountOption.exact);
      return PaginatedResponse<Job>(items: (data as List).map((r) => Job.fromSupabase(r as Map<String, dynamic>)).toList(), total: count.count, page: filter.page, pageSize: filter.pageSize);
    } catch (e) {
      throw SupabaseException('Failed to fetch jobs: $e');
    }
  }

  @override
  Future<Job> getJobById(String id) async {
    try {
      final data = await _client.from('jobs').select().eq('id', id).single();
      return Job.fromSupabase(data);
    } catch (e) {
      throw SupabaseException('Job $id not found: $e');
    }
  }

  @override
  Future<List<Job>> getSavedJobs() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];
      final data = await _client.from('saved_jobs').select('job_id, jobs(*)').eq('user_id', userId);
      return (data as List).map((r) => Job.fromSupabase((r as Map<String, dynamic>)['jobs'] as Map<String, dynamic>).copyWith(isSaved: true)).toList();
    } catch (e) {
      throw SupabaseException('Failed to fetch saved jobs: $e');
    }
  }

  @override
  Future<List<Job>> getAppliedJobs() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];
      final data = await _client.from('job_applications').select('status, jobs(*)').eq('user_id', userId);
      return (data as List).map((r) { final row = r as Map<String, dynamic>; return Job.fromSupabase(row['jobs'] as Map<String, dynamic>).copyWith(isApplied: true, applicationStatus: row['status'] as String?); }).toList();
    } catch (e) {
      throw SupabaseException('Failed to fetch applied jobs: $e');
    }
  }

  @override
  Future<void> saveJob(String jobId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const SupabaseException('Not authenticated');
    await _client.from('saved_jobs').insert({'user_id': userId, 'job_id': jobId});
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const SupabaseException('Not authenticated');
    await _client.from('saved_jobs').delete().eq('user_id', userId).eq('job_id', jobId);
  }
}
