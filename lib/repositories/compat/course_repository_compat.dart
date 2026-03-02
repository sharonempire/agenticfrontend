import 'package:logger/logger.dart';

import '../../config/backend_mode.dart';
import '../../config/feature_flags.dart';
import '../../core/error/app_exception.dart';
import '../../core/error/fallback_helper.dart';
import '../../models/common/paginated_response.dart';
import '../../models/course/course.dart';
import '../course_repository.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Compatibility adapter for courses.
/// Routes calls through FastAPI when enabled, falls back to Supabase.
class CourseRepositoryCompat implements CourseRepository {
  CourseRepositoryCompat({
    required this.fastApi,
    required this.supabase,
    required this.mode,
  });

  final CourseRepository fastApi;
  final CourseRepository supabase;
  final BackendMode mode;

  /// Effective mode: respects both global mode and per-feature flag.
  BackendMode get _effectiveMode =>
      FeatureFlags.courseFinderFastApi ? mode : BackendMode.supabaseOnly;

  @override
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter) =>
      _tryWithFallback('getCourses', () => fastApi.getCourses(filter), () => supabase.getCourses(filter));

  @override
  Future<Course> getCourseById(String id) =>
      _tryWithFallback('getCourseById', () => fastApi.getCourseById(id), () => supabase.getCourseById(id));

  @override
  Future<PaginatedResponse<Course>> searchCourses(String query, {int page = 1, int pageSize = 20}) =>
      _tryWithFallback(
        'searchCourses',
        () => fastApi.searchCourses(query, page: page, pageSize: pageSize),
        () => supabase.searchCourses(query, page: page, pageSize: pageSize),
      );

  @override
  Future<PaginatedResponse<Course>> getEligibleCourses({int page = 1, int pageSize = 20}) =>
      _tryWithFallback(
        'getEligibleCourses',
        () => fastApi.getEligibleCourses(page: page, pageSize: pageSize),
        () => supabase.getEligibleCourses(page: page, pageSize: pageSize),
      );

  @override
  Future<List<String>> getCategories() =>
      _tryWithFallback('getCategories', () => fastApi.getCategories(), () => supabase.getCategories());

  @override
  Future<List<String>> getLevels() =>
      _tryWithFallback('getLevels', () => fastApi.getLevels(), () => supabase.getLevels());

  /// Core fallback engine.
  /// 1. If supabaseOnly → go directly to Supabase.
  /// 2. If fastapiPreferred → try FastAPI, fallback to Supabase on qualifying errors.
  /// 3. If fastapiOnly → FastAPI only, errors propagate.
  Future<T> _tryWithFallback<T>(
    String method,
    Future<T> Function() fastApiCall,
    Future<T> Function() supabaseCall,
  ) async {
    final effective = _effectiveMode;

    if (effective == BackendMode.supabaseOnly) {
      return supabaseCall();
    }

    try {
      return await fastApiCall();
    } on AppException catch (e) {
      if (shouldFallback(e, effective)) {
        logFallback('CourseRepo', method, e);
        return supabaseCall();
      }
      rethrow;
    } catch (e) {
      // Unexpected error — fallback if not fastapiOnly.
      if (effective == BackendMode.fastapiPreferred) {
        _log.w('[CourseRepo.$method] Unexpected error ($e), falling back to Supabase');
        return supabaseCall();
      }
      rethrow;
    }
  }
}
