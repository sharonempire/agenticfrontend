import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/app_exception.dart';
import '../../models/common/paginated_response.dart';
import '../../models/course/course.dart';
import '../course_repository.dart';

/// Supabase-backed course repository.
/// This is the existing data path that the compat layer falls back to.
class SupabaseCourseRepository implements CourseRepository {
  SupabaseCourseRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter) async {
    try {
      var query = _client.from('courses').select();

      if (filter.query != null && filter.query!.isNotEmpty) {
        query = query.ilike('title', '%${filter.query}%');
      }
      if (filter.category != null) {
        query = query.eq('category', filter.category!);
      }
      if (filter.level != null) {
        query = query.eq('level', filter.level!);
      }
      if (filter.isFree == true) {
        query = query.eq('is_free', true);
      }
      if (filter.provider != null) {
        query = query.eq('provider', filter.provider!);
      }

      final from = (filter.page - 1) * filter.pageSize;
      final to = from + filter.pageSize - 1;

      final data = await query.range(from, to);
      final rows = data as List;

      // Supabase doesn't return total count with range by default.
      // Use count query for accurate pagination.
      final countResult = await _client.from('courses').select('id').count(CountOption.exact);
      final total = countResult.count;

      return PaginatedResponse<Course>(
        items: rows.map((r) => Course.fromSupabase(r as Map<String, dynamic>)).toList(),
        total: total,
        page: filter.page,
        pageSize: filter.pageSize,
      );
    } catch (e) {
      throw SupabaseException('Failed to fetch courses: $e');
    }
  }

  @override
  Future<Course> getCourseById(String id) async {
    try {
      final data = await _client.from('courses').select().eq('id', id).single();
      return Course.fromSupabase(data);
    } catch (e) {
      throw SupabaseException('Failed to fetch course $id: $e');
    }
  }

  @override
  Future<PaginatedResponse<Course>> searchCourses(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return getCourses(CourseFilter(query: query, page: page, pageSize: pageSize));
  }

  @override
  Future<PaginatedResponse<Course>> getEligibleCourses({
    int page = 1,
    int pageSize = 20,
  }) async {
    // TODO: Supabase doesn't have an eligibility endpoint.
    // Return all courses as a fallback.
    return getCourses(CourseFilter(page: page, pageSize: pageSize));
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final data = await _client
          .from('courses')
          .select('category')
          .not('category', 'is', null);
      final rows = data as List;
      return rows
          .map((r) => (r as Map<String, dynamic>)['category'] as String?)
          .where((c) => c != null)
          .cast<String>()
          .toSet()
          .toList();
    } catch (e) {
      throw SupabaseException('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<String>> getLevels() async {
    try {
      final data = await _client
          .from('courses')
          .select('level')
          .not('level', 'is', null);
      final rows = data as List;
      return rows
          .map((r) => (r as Map<String, dynamic>)['level'] as String?)
          .where((l) => l != null)
          .cast<String>()
          .toSet()
          .toList();
    } catch (e) {
      throw SupabaseException('Failed to fetch levels: $e');
    }
  }
}
