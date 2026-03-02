import 'package:logger/logger.dart';
import '../../core/config/app_config.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/fallback_helper.dart';
import '../../models/common/paginated_response.dart';
import '../../models/course/course.dart';
import '../interfaces/course_repository.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

class CourseRepositoryCompat implements CourseRepository {
  CourseRepositoryCompat({required this.fastApi, required this.supabase});
  final CourseRepository fastApi;
  final CourseRepository supabase;

  BackendMode get _mode => AppConfig.courseFinderFastApi ? AppConfig.backendMode : BackendMode.supabaseOnly;

  @override
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter) => _try('getCourses', () => fastApi.getCourses(filter), () => supabase.getCourses(filter));

  @override
  Future<Course> getCourseById(String id) => _try('getCourseById', () => fastApi.getCourseById(id), () => supabase.getCourseById(id));

  @override
  Future<List<String>> getCategories() => _try('getCategories', () => fastApi.getCategories(), () => supabase.getCategories());

  Future<T> _try<T>(String m, Future<T> Function() fast, Future<T> Function() supa) async {
    if (_mode == BackendMode.supabaseOnly) return supa();
    try { return await fast(); }
    on AppException catch (e) { if (shouldFallback(e, _mode)) { logFallback('CourseRepo', m, e); return supa(); } rethrow; }
    catch (e) { if (_mode == BackendMode.fastapiPreferred) { _log.w('[CourseRepo.$m] Unexpected error ($e)'); return supa(); } rethrow; }
  }
}
