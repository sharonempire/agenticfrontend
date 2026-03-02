import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agenticfrontend/config/backend_mode.dart';
import 'package:agenticfrontend/core/error/app_exception.dart';
import 'package:agenticfrontend/models/common/paginated_response.dart';
import 'package:agenticfrontend/models/job/job.dart';
import 'package:agenticfrontend/repositories/compat/job_repository_compat.dart';
import 'package:agenticfrontend/repositories/job_repository.dart';

// ── Fake implementations ────────────────────────────────────────────────────

class _FakeJobRepo implements JobRepository {
  _FakeJobRepo({this.jobs, this.error});

  final List<Job>? jobs;
  final AppException? error;
  int callCount = 0;

  PaginatedResponse<Job> _paginated() => PaginatedResponse<Job>(
        items: jobs ?? [],
        total: jobs?.length ?? 0,
        page: 1,
        pageSize: 20,
      );

  @override
  Future<PaginatedResponse<Job>> getJobs(JobFilter filter) async {
    callCount++;
    if (error != null) throw error!;
    return _paginated();
  }

  @override
  Future<Job> getJobById(String id) async {
    callCount++;
    if (error != null) throw error!;
    return jobs!.first;
  }

  @override
  Future<PaginatedResponse<Job>> searchJobs(String query, {int page = 1, int pageSize = 20}) async {
    callCount++;
    if (error != null) throw error!;
    return _paginated();
  }

  @override
  Future<List<Job>> getSavedJobs() async {
    callCount++;
    if (error != null) throw error!;
    return jobs ?? [];
  }

  @override
  Future<List<Job>> getAppliedJobs() async {
    callCount++;
    if (error != null) throw error!;
    return jobs ?? [];
  }

  @override
  Future<void> saveJob(String jobId) async {
    callCount++;
    if (error != null) throw error!;
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    callCount++;
    if (error != null) throw error!;
  }
}

final _testJobs = [
  const Job(id: '1', title: 'Flutter Developer', company: 'Acme'),
  const Job(id: '2', title: 'Backend Engineer', company: 'BigCo'),
];

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: '''
FF_JOB_FINDER_FASTAPI=true
''');
  });

  group('JobRepositoryCompat', () {
    test('supabaseOnly mode skips FastAPI', () async {
      final fastApi = _FakeJobRepo(jobs: _testJobs);
      final supabase = _FakeJobRepo(jobs: _testJobs);

      final compat = JobRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.supabaseOnly,
      );

      final result = await compat.getJobs(const JobFilter());
      expect(result.items.length, 2);
      expect(fastApi.callCount, 0);
      expect(supabase.callCount, 1);
    });

    test('fastapiPreferred uses FastAPI on success', () async {
      final fastApi = _FakeJobRepo(jobs: _testJobs);
      final supabase = _FakeJobRepo(jobs: _testJobs);

      final compat = JobRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getJobs(const JobFilter());
      expect(result.items.length, 2);
      expect(fastApi.callCount, 1);
      expect(supabase.callCount, 0);
    });

    test('fastapiPreferred falls back on NetworkException', () async {
      final fastApi = _FakeJobRepo(error: const NetworkException('timeout'));
      final supabase = _FakeJobRepo(jobs: _testJobs);

      final compat = JobRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getJobs(const JobFilter());
      expect(result.items.length, 2);
      expect(fastApi.callCount, 1);
      expect(supabase.callCount, 1);
    });

    test('fastapiPreferred falls back on 500', () async {
      final fastApi = _FakeJobRepo(
        error: const ApiException('Server error', statusCode: 500),
      );
      final supabase = _FakeJobRepo(jobs: _testJobs);

      final compat = JobRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      final result = await compat.getJobs(const JobFilter());
      expect(result.items.length, 2);
    });

    test('fastapiOnly propagates errors', () async {
      final fastApi = _FakeJobRepo(
        error: const NetworkException('offline'),
      );
      final supabase = _FakeJobRepo(jobs: _testJobs);

      final compat = JobRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiOnly,
      );

      expect(
        () => compat.getJobs(const JobFilter()),
        throwsA(isA<NetworkException>()),
      );
    });

    test('saveJob routes through compat layer', () async {
      final fastApi = _FakeJobRepo(jobs: _testJobs);
      final supabase = _FakeJobRepo(jobs: _testJobs);

      final compat = JobRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      await compat.saveJob('1');
      expect(fastApi.callCount, 1);
      expect(supabase.callCount, 0);
    });

    test('saveJob falls back on failure', () async {
      final fastApi = _FakeJobRepo(
        error: const ApiException('Unauthorized', statusCode: 401),
      );
      final supabase = _FakeJobRepo(jobs: _testJobs);

      final compat = JobRepositoryCompat(
        fastApi: fastApi,
        supabase: supabase,
        mode: BackendMode.fastapiPreferred,
      );

      await compat.saveJob('1');
      expect(fastApi.callCount, 1);
      expect(supabase.callCount, 1);
    });
  });

  group('Job model parsing', () {
    test('fromJson handles standard fields', () {
      final job = Job.fromJson({
        'id': 99,
        'title': 'Senior Dev',
        'company': 'TechCorp',
        'is_remote': true,
        'salary_min': 80000,
        'salary_max': 120000,
        'skills': ['dart', 'flutter'],
        'posted_at': '2025-01-01T00:00:00Z',
      });

      expect(job.id, '99');
      expect(job.title, 'Senior Dev');
      expect(job.company, 'TechCorp');
      expect(job.isRemote, true);
      expect(job.salaryMin, 80000.0);
      expect(job.salaryMax, 120000.0);
      expect(job.skills, ['dart', 'flutter']);
      expect(job.postedAt, isNotNull);
    });

    test('fromJson handles alternate field names', () {
      final job = Job.fromJson({
        'job_id': 'xyz',
        'job_title': 'Engineer',
        'company_name': 'StartupCo',
        'logo_url': 'http://logo.png',
        'job_type': 'contract',
        'level': 'senior',
        'apply_url': 'http://apply',
      });

      expect(job.id, 'xyz');
      expect(job.title, 'Engineer');
      expect(job.company, 'StartupCo');
      expect(job.companyLogo, 'http://logo.png');
      expect(job.type, 'contract');
      expect(job.experienceLevel, 'senior');
      expect(job.url, 'http://apply');
    });

    test('copyWith preserves fields and overrides', () {
      const job = Job(id: '1', title: 'Dev', isSaved: false, isApplied: false);
      final saved = job.copyWith(isSaved: true);
      expect(saved.isSaved, true);
      expect(saved.isApplied, false);
      expect(saved.title, 'Dev');
    });
  });
}
