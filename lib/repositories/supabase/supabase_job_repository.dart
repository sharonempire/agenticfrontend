import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/app_exception.dart';
import '../../models/common/paginated_response.dart';
import '../../models/job/job.dart';
import '../job_repository.dart';

/// Supabase-backed job repository.
class SupabaseJobRepository implements JobRepository {
  SupabaseJobRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter) async {
    try {
      var query = _client.from('jobs').select();

      if (filter.query != null && filter.query!.isNotEmpty) {
        query = query.ilike('title', '%${filter.query}%');
      }
      if (filter.category != null) {
        query = query.eq('category', filter.category!);
      }
      if (filter.type != null) {
        query = query.eq('type', filter.type!);
      }
      if (filter.location != null) {
        query = query.ilike('location', '%${filter.location}%');
      }
      if (filter.isRemote == true) {
        query = query.eq('is_remote', true);
      }
      if (filter.experienceLevel != null) {
        query = query.eq('experience_level', filter.experienceLevel!);
      }

      final from = (filter.page - 1) * filter.pageSize;
      final to = from + filter.pageSize - 1;

      final data = await query.range(from, to);
      final rows = data as List;

      final countResult = await _client.from('jobs').select('id').count(CountOption.exact);
      final total = countResult.count;

      return PaginatedResponse<Job>(
        items: rows.map((r) => Job.fromSupabase(r as Map<String, dynamic>)).toList(),
        total: total,
        page: filter.page,
        pageSize: filter.pageSize,
      );
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
      throw SupabaseException('Failed to fetch job $id: $e');
    }
  }

  @override
  Future<PaginatedResponse<Job>> searchJobs(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return getJobs(JobFilter(query: query, page: page, pageSize: pageSize));
  }

  @override
  Future<List<Job>> getSavedJobs() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('saved_jobs')
          .select('job_id, jobs(*)')
          .eq('user_id', userId);
      final rows = data as List;
      return rows.map((r) {
        final jobData = (r as Map<String, dynamic>)['jobs'] as Map<String, dynamic>;
        return Job.fromSupabase(jobData).copyWith(isSaved: true);
      }).toList();
    } catch (e) {
      throw SupabaseException('Failed to fetch saved jobs: $e');
    }
  }

  @override
  Future<List<Job>> getAppliedJobs() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('job_applications')
          .select('job_id, status, jobs(*)')
          .eq('user_id', userId);
      final rows = data as List;
      return rows.map((r) {
        final row = r as Map<String, dynamic>;
        final jobData = row['jobs'] as Map<String, dynamic>;
        return Job.fromSupabase(jobData).copyWith(
          isApplied: true,
          applicationStatus: row['status'] as String?,
        );
      }).toList();
    } catch (e) {
      throw SupabaseException('Failed to fetch applied jobs: $e');
    }
  }

  @override
  Future<void> saveJob(String jobId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const SupabaseException('Not authenticated');

      await _client.from('saved_jobs').insert({
        'user_id': userId,
        'job_id': jobId,
      });
    } catch (e) {
      if (e is SupabaseException) rethrow;
      throw SupabaseException('Failed to save job: $e');
    }
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const SupabaseException('Not authenticated');

      await _client
          .from('saved_jobs')
          .delete()
          .eq('user_id', userId)
          .eq('job_id', jobId);
    } catch (e) {
      if (e is SupabaseException) rethrow;
      throw SupabaseException('Failed to unsave job: $e');
    }
  }
}
