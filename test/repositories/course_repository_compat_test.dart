import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agenticfrontend/models/common/paginated_response.dart';
import 'package:agenticfrontend/models/course/course.dart';
import 'package:agenticfrontend/repositories/interfaces/course_repository.dart';
import 'package:agenticfrontend/repositories/compat/course_repository_compat.dart';

// ── Fake implementations ────────────────────────────────────────────────────

class _FakeCourseRepo implements CourseRepository {
  _FakeCourseRepo({this.courses});

  final List<Course>? courses;
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

    return _paginated();
  }

  @override
  Future<Course> getCourseById(String id) async {
    callCount++;

    return courses!.first;
  }

  @override
  Future<List<String>> getCategories() async {
    callCount++;

    return ['Tech', 'Business'];
  }
}

final _testCourses = [
  const Course(id: '1', title: 'Flutter Basics'),
  const Course(id: '2', title: 'Advanced Dart'),
];

void main() {
  setUpAll(() {
    // Default: no feature flag → supabaseOnly mode
    dotenv.testLoad(fileInput: '');
  });

  group('CourseRepositoryCompat – supabaseOnly (default)', () {
    test('skips FastAPI entirely', () async {
      final fastApi = _FakeCourseRepo(courses: _testCourses);
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(fastApi: fastApi, supabase: supabase);

      final result = await compat.getCourses(const CourseFilter());
      expect(result.items.length, 2);
      expect(fastApi.callCount, 0);
      expect(supabase.callCount, 1);
    });

    test('getCourseById routes to supabase', () async {
      final fastApi = _FakeCourseRepo(courses: _testCourses);
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(fastApi: fastApi, supabase: supabase);

      final course = await compat.getCourseById('1');
      expect(course.id, '1');
      expect(fastApi.callCount, 0);
      expect(supabase.callCount, 1);
    });

    test('getCategories routes to supabase', () async {
      final fastApi = _FakeCourseRepo(courses: _testCourses);
      final supabase = _FakeCourseRepo(courses: _testCourses);

      final compat = CourseRepositoryCompat(fastApi: fastApi, supabase: supabase);

      final cats = await compat.getCategories();
      expect(cats, ['Tech', 'Business']);
      expect(fastApi.callCount, 0);
      expect(supabase.callCount, 1);
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
