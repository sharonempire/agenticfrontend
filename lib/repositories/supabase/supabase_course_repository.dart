import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/app_exception.dart';
import '../../models/common/paginated_response.dart';
import '../../models/course/course.dart';
import '../interfaces/course_repository.dart';

class SupabaseCourseRepository implements CourseRepository {
  SupabaseCourseRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  @override
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter) async {
    try {
      var query = _client.from('courses').select();
      if (filter.query != null && filter.query!.isNotEmpty) query = query.ilike('title', '%${filter.query}%');
      if (filter.category != null) query = query.eq('category', filter.category!);
      if (filter.level != null) query = query.eq('level', filter.level!);
      if (filter.isFree == true) query = query.eq('is_free', true);
      final from = (filter.page - 1) * filter.pageSize;
      final data = await query.range(from, from + filter.pageSize - 1);
      final count = await _client.from('courses').select('id').count(CountOption.exact);
      return PaginatedResponse<Course>(items: (data as List).map((r) => Course.fromSupabase(r as Map<String, dynamic>)).toList(), total: count.count, page: filter.page, pageSize: filter.pageSize);
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
      throw SupabaseException('Course $id not found: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final data = await _client.from('courses').select('category').not('category', 'is', null);
      return (data as List).map((r) => (r as Map<String, dynamic>)['category'] as String?).where((c) => c != null).cast<String>().toSet().toList();
    } catch (e) {
      throw SupabaseException('Failed to fetch categories: $e');
    }
  }
}
