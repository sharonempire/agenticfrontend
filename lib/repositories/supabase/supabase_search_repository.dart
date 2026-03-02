import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/app_exception.dart';
import '../../models/common/paginated_response.dart';
import '../../models/search/search_result.dart';
import '../search_repository.dart';

/// Supabase-backed search — performs parallel queries across tables.
class SupabaseSearchRepository implements SearchRepository {
  SupabaseSearchRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<PaginatedResponse<SearchResult>> search(SearchQuery query) async {
    try {
      final results = <SearchResult>[];

      // Search courses
      if (query.types == null || query.types!.contains('course')) {
        final courses = await _client
            .from('courses')
            .select('id, title, description, image_url')
            .ilike('title', '%${query.query}%')
            .limit(query.pageSize);
        for (final row in courses as List) {
          final r = row as Map<String, dynamic>;
          results.add(SearchResult(
            id: '${r['id']}',
            type: 'course',
            title: r['title'] as String? ?? '',
            subtitle: r['description'] as String?,
            imageUrl: r['image_url'] as String?,
          ));
        }
      }

      // Search jobs
      if (query.types == null || query.types!.contains('job')) {
        final jobs = await _client
            .from('jobs')
            .select('id, title, company, company_logo')
            .ilike('title', '%${query.query}%')
            .limit(query.pageSize);
        for (final row in jobs as List) {
          final r = row as Map<String, dynamic>;
          results.add(SearchResult(
            id: '${r['id']}',
            type: 'job',
            title: r['title'] as String? ?? '',
            subtitle: r['company'] as String?,
            imageUrl: r['company_logo'] as String?,
          ));
        }
      }

      return PaginatedResponse<SearchResult>(
        items: results,
        total: results.length,
        page: query.page,
        pageSize: query.pageSize,
      );
    } catch (e) {
      throw SupabaseException('Search failed: $e');
    }
  }
}
