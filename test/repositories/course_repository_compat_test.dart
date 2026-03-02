import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agenticfrontend/config/backend_mode.dart';
import 'package:agenticfrontend/core/error/app_exception.dart';
import 'package:agenticfrontend/models/common/paginated_response.dart';
import 'package:agenticfrontend/models/course/course.dart';
import 'package:agenticfrontend/repositories/compat/course_repository_compat.dart';
import 'package:agenticfrontend/repositories/course_repository.dart';

// ── Fake implementations ────────────────────────────────────────────────────

class _FakeCourseRepo implements CourseRepository {
  _FakeCourseRepo({this.courses, this.error});

  final List<Course>? courses;
  final AppException? error;
  int callCount = 0;

  PaginatedResponse<Course> _paginated() => PaginatedResponse<Course>(
        items: courses ?? [],
        total: courses?.length ?? 0,
        page: 1,
        pageSize: 20,
      );

  @override
  Future<PaginatedResponse<Course>> getCourses(CourseFilter filter) async {
    callCount++;
    if (error != null) throw error!;
    return _paginated();
  }

  @override
  Future<Course> getCourseById(String id) async {
    callCount++;
    if (error != null) throw error!;
    return courses!.first;
  }

  @override
  Future<PaginatedResponse<Course>> searchCourses(String query, {int page = 1, int pageSize = 20}) async {
    callCount++;
    if (error != null) throw error!;
    return _paginated();
  }

  @override
  Future<PaginatedResponse<Course>> getEligibleCourses({int page = 1, int pageSize = 20}) async {
    callCount++;
    if (error != null) throw error!;
    return _paginated();
  }

  @override
  Future<List<String>> getCategories() async {
    callCount++;
    if (error != null) throw error!;
    return ['Tech', 'Business'];
  }

  @override
  Future<List<String>> getLevels() async {
    callCount++;
    if (error != null) throw error!;
    return ['Beginner', 'Advanced'];
  }
}

final _testCourses = [
  const Course(id: '1', title: 'Flutter Basics'),
  const Course(id: '2', title: 'Advanced Dart'),
];

void main() {
  setUpAll(() {
    // Load env with feature flags enabled for testing.
    dotenv.testLoad(fileInput: '''
FF_COURSE_FINDER_FASTAPI=true
''');
  });

  group('CourseRepositoryCompat', () {
    test('supabaseOnly mode skips FastAPI entirely', () async {
      final fastApi = _FakeCourseRepo(courses: _testCourses);
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.supabaseOnly,
      );

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
      expect(fastApi.callCount, 0);
      expect(supabase.callCount, 1);
    });

    test('fastapiPreferred uses FastAPI on success', () async {
      final fastApi = _FakeCourseRepo(courses: _testCourses);
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
      expect(fastApi.callCount, 1);
      expect(supabase.callCount, 0);
    });

    test('fastapiPreferred falls back to Supabase on NetworkException', () async {
      final fastApi = _FakeCourseRepo(
        error: const NetworkException('timeout'),
      );
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
      expect(fastApi.callCount, 1);
      expect(supabase.callCount, 1);
    });

    test('fastapiPreferred falls back on 401 Unauthorized', () async {
      final fastApi = _FakeCourseRepo(
        error: const ApiException('Unauthorized', statusCode: 401),
      );
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
      expect(supabase.callCount, 1);
    });

    test('fastapiPreferred falls back on 404 Not Found', () async {
      final fastApi = _FakeCourseRepo(
        error: const ApiException('Not found', statusCode: 404),
      );
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
    });

    test('fastapiPreferred falls back on 500 Server Error', () async {
      final fastApi = _FakeCourseRepo(
        error: const ApiException('Internal error', statusCode: 500),
      );
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
    });

    test('fastapiPreferred falls back on ParseException', () async {
      final fastApi = _FakeCourseRepo(
        error: const ParseException('bad json'),
      );
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
    });

    test('fastapiOnly does NOT fallback — propagates error', () async {
      final fastApi = _FakeCourseRepo(
        error: const NetworkException('timeout'),
      );
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiOnly,
      );

      expect(
        () => compat.getCourses(const CourseFilter()),
        throwsA(isA<NetworkException>()),
      );
    });

    test('getCourseById routes correctly', () async {
      final fastApi = _FakeCourseRepo(courses: _testCourses);
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getCourseById('1');
      expect(result.id, '1');
      expect(fastApi.callCount, 1);
    });
  });

  group('Course model parsing', () {
    test('fromJson handles standard fields', () {
      final course = Course.fromJson({
        'id': 42,
        'title': 'Test Course',
        'provider': 'Coursera',
        'rating': 4.5,
        'price': 0,
        'tags': ['dart', 'flutter'],
      });

      expect(course.id, '42');
      expect(course.title, 'Test Course');
      expect(course.provider, 'Coursera');
      expect(course.rating, 4.5);
      expect(course.isFree, true);
      expect(course.tags, ['dart', 'flutter']);
    });

    test('fromJson handles alternate field names', () {
      final course = Course.fromJson({
        'course_id': 'abc',
        'name': 'Alt Name',
        'institution': 'MIT',
        'thumbnail': 'http://img.png',
        'difficulty': 'beginner',
      });

      expect(course.id, 'abc');
      expect(course.title, 'Alt Name');
      expect(course.provider, 'MIT');
      expect(course.imageUrl, 'http://img.png');
      expect(course.level, 'beginner');
    });

    test('fromJson handles null/missing fields gracefully', () {
      final course = Course.fromJson({});
      expect(course.id, '');
      expect(course.title, '');
      expect(course.tags, isEmpty);
    });
  });
}
