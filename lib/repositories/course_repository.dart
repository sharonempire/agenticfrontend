import '../models/common/paginated_response.dart';
import '../models/course/course.dart';

/// Abstract contract for course data access.
/// Implemented by Supabase, FastAPI, and Compat adapters.
abstract class CourseRepository {
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter);
  Future<Course> getCourseById(String id);
  Future<PaginatedResponse<Course>> searchCourses(String query, {int page = 1, int pageSize = 20});
  Future<PaginatedResponse<Course>> getEligibleCourses({int page = 1, int pageSize = 20});
  Future<List<String>> getCategories();
  Future<List<String>> getLevels();
}
