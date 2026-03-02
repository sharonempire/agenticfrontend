import '../../core/error/app_exception.dart';
import '../../core/network/fastapi_client.dart';
import '../../models/common/paginated_response.dart';
import '../../models/course/course.dart';
import '../course_repository.dart';

/// FastAPI-backed course repository.
/// Maps /api/v1/courses/* endpoints to [CourseRepository] contract.
class FastApiCourseRepository implements CourseRepository {
  FastApiCourseRepository({required this.client});

  final FastApiClient client;

  @override
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter) async {
    final response = await client.get<Map<String, dynamic>>(
      '/courses/',
      queryParameters: filter.toQueryParams(),
    );
    return _parsePaginatedCourses(response.data!, filter.page, filter.pageSize);
  }

  @override
  Future<Course> getCourseById(String id) async {
    final response = await client.get<Map<String, dynamic>>('/courses/$id');
    final data = response.data;
    if (data == null) {
      throw const ApiException('Course not found', statusCode: 404);
    }
    return Course.fromJson(data);
  }

  @override
  Future<PaginatedResponse<Course>> searchCourses(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await client.get<Map<String, dynamic>>(
      '/courses/search',
      queryParameters: {'q': query, 'page': page, 'page_size': pageSize},
    );
    return _parsePaginatedCourses(response.data!, page, pageSize);
  }

  @override
  Future<PaginatedResponse<Course>> getEligibleCourses({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await client.get<Map<String, dynamic>>(
      '/courses/eligible',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return _parsePaginatedCourses(response.data!, page, pageSize);
  }

  @override
  Future<List<String>> getCategories() async {
    // TODO: Backend may not have a dedicated categories endpoint.
    // Attempt to parse from course list metadata or a dedicated route.
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/courses/categories',
      );
      final data = response.data;
      if (data != null && data['categories'] is List) {
        return (data['categories'] as List).cast<String>();
      }
      return [];
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw const NotImplementedException('Categories endpoint not available');
      }
      rethrow;
    }
  }

  @override
  Future<List<String>> getLevels() async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/courses/levels',
      );
      final data = response.data;
      if (data != null && data['levels'] is List) {
        return (data['levels'] as List).cast<String>();
      }
      return [];
    } on ApiException catch (e) {
      if (e.isNotFound) {
        throw const NotImplementedException('Levels endpoint not available');
      }
      rethrow;
    }
  }

  /// Parse paginated courses from either envelope or raw list.
  PaginatedResponse<Course> _parsePaginatedCourses(
    Map<String, dynamic> data,
    int fallbackPage,
    int fallbackPageSize,
  ) {
    // If the response has an "items" key, treat as paginated envelope.
    if (data.containsKey('items')) {
      return PaginatedResponse.fromJson(data, Course.fromJson);
    }

    // If the response has a "results" key (alternate convention).
    if (data.containsKey('results')) {
      final items = (data['results'] as List)
          .cast<Map<String, dynamic>>()
          .map(Course.fromJson)
          .toList();
      return PaginatedResponse<Course>(
        items: items,
        total: data['total'] as int? ?? data['count'] as int? ?? items.length,
        page: data['page'] as int? ?? fallbackPage,
        pageSize: data['page_size'] as int? ?? fallbackPageSize,
      );
    }

    // Fallback: response is the list itself nested under "data".
    if (data.containsKey('data') && data['data'] is List) {
      final items = (data['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(Course.fromJson)
          .toList();
      return PaginatedResponse<Course>(
        items: items,
        total: data['total'] as int? ?? items.length,
        page: fallbackPage,
        pageSize: fallbackPageSize,
      );
    }

    throw const ParseException('Unable to parse courses response');
  }
}
