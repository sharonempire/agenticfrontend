import '../../core/error/app_exception.dart';
import '../../core/network/fastapi_client.dart';
import '../../models/common/paginated_response.dart';
import '../../models/course/course.dart';
import '../interfaces/course_repository.dart';

class FastApiCourseRepository implements CourseRepository {
  FastApiCourseRepository({required this.client});
  final FastApiClient client;

  @override
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter) async {
    final response = await client.get<Map<String, dynamic>>('/courses/', queryParameters: filter.toQueryParams());
    return PaginatedResponse.fromJson(response.data!, Course.fromJson);
  }

  @override
  Future<Course> getCourseById(String id) async {
    final response = await client.get<Map<String, dynamic>>('/courses/$id');
    if (response.data == null) throw const ApiException('Course not found', statusCode: 404);
    return Course.fromJson(response.data!);
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await client.get<Map<String, dynamic>>('/courses/categories');
      if (response.data?['categories'] is List) return (response.data!['categories'] as List).cast<String>();
      return [];
    } on ApiException catch (e) {
      if (e.isNotFound) throw const NotImplementedException('Categories endpoint not available');
      rethrow;
    }
  }
}
