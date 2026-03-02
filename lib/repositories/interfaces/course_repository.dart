import '../../models/common/paginated_response.dart';
import '../../models/course/course.dart';

abstract class CourseRepository {
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter);
  Future<Course> getCourseById(String id);
  Future<List<String>> getCategories();
}
