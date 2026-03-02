import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_mode.dart';
import '../core/network/fastapi_client.dart';
import '../core/storage/token_storage.dart';
import '../repositories/ai_copilot_repository.dart';
import '../repositories/compat/ai_copilot_repository_compat.dart';
import '../repositories/compat/course_repository_compat.dart';
import '../repositories/compat/job_repository_compat.dart';
import '../repositories/compat/search_repository_compat.dart';
import '../repositories/course_repository.dart';
import '../repositories/fastapi/fastapi_ai_copilot_repository.dart';
import '../repositories/fastapi/fastapi_course_repository.dart';
import '../repositories/fastapi/fastapi_job_repository.dart';
import '../repositories/fastapi/fastapi_search_repository.dart';
import '../repositories/job_repository.dart';
import '../repositories/search_repository.dart';
import '../repositories/supabase/supabase_course_repository.dart';
import '../repositories/supabase/supabase_job_repository.dart';
import '../repositories/supabase/supabase_search_repository.dart';

// ── Infrastructure ──────────────────────────────────────────────────────────

final backendModeProvider = Provider<BackendMode>((ref) {
  return resolveBackendMode();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final fastApiClientProvider = Provider<FastApiClient>((ref) {
  return FastApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});

// ── Supabase Repositories (raw) ─────────────────────────────────────────────

final supabaseCourseRepoProvider = Provider<CourseRepository>((ref) {
  return SupabaseCourseRepository();
});

final supabaseJobRepoProvider = Provider<JobRepository>((ref) {
  return SupabaseJobRepository();
});

final supabaseSearchRepoProvider = Provider<SearchRepository>((ref) {
  return SupabaseSearchRepository();
});

// ── FastAPI Repositories (raw) ──────────────────────────────────────────────

final fastApiCourseRepoProvider = Provider<CourseRepository>((ref) {
  return FastApiCourseRepository(client: ref.watch(fastApiClientProvider));
});

final fastApiJobRepoProvider = Provider<JobRepository>((ref) {
  return FastApiJobRepository(client: ref.watch(fastApiClientProvider));
});

final fastApiSearchRepoProvider = Provider<SearchRepository>((ref) {
  return FastApiSearchRepository(client: ref.watch(fastApiClientProvider));
});

final fastApiAiCopilotRepoProvider = Provider<AiCopilotRepository>((ref) {
  return FastApiAiCopilotRepository(client: ref.watch(fastApiClientProvider));
});

// ── Compat Repositories (what the UI consumes) ──────────────────────────────

/// The course repository used by all UI/controllers.
/// Automatically routes between FastAPI and Supabase.
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryCompat(
    fastApi: ref.watch(fastApiCourseRepoProvider),
    supabase: ref.watch(supabaseCourseRepoProvider),
    mode: ref.watch(backendModeProvider),
  );
});

/// The job repository used by all UI/controllers.
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepositoryCompat(
    fastApi: ref.watch(fastApiJobRepoProvider),
    supabase: ref.watch(supabaseJobRepoProvider),
    mode: ref.watch(backendModeProvider),
  );
});

/// The search repository used by all UI/controllers.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryCompat(
    fastApi: ref.watch(fastApiSearchRepoProvider),
    supabase: ref.watch(supabaseSearchRepoProvider),
    mode: ref.watch(backendModeProvider),
  );
});

/// The AI copilot repository — no Supabase fallback, graceful degradation.
final aiCopilotRepositoryProvider = Provider<AiCopilotRepository>((ref) {
  return AiCopilotRepositoryCompat(
    fastApi: ref.watch(fastApiAiCopilotRepoProvider),
  );
});
