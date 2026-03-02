import 'package:get_it/get_it.dart';
import '../network/fastapi_client.dart';
import '../storage/token_storage.dart';
import '../../repositories/interfaces/course_repository.dart';
import '../../repositories/interfaces/job_repository.dart';
import '../../repositories/supabase/supabase_course_repository.dart';
import '../../repositories/supabase/supabase_job_repository.dart';
import '../../repositories/fastapi/fastapi_course_repository.dart';
import '../../repositories/fastapi/fastapi_job_repository.dart';
import '../../repositories/compat/course_repository_compat.dart';
import '../../repositories/compat/job_repository_compat.dart';
import '../../blocs/course/course_list_bloc.dart';
import '../../blocs/course/course_detail_bloc.dart';
import '../../blocs/job/job_list_bloc.dart';
import '../../blocs/job/job_detail_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton(() => FastApiClient(tokenStorage: sl<TokenStorage>()));

  // Supabase repos
  sl.registerLazySingleton(() => SupabaseCourseRepository());
  sl.registerLazySingleton(() => SupabaseJobRepository());

  // FastAPI repos
  sl.registerLazySingleton(() => FastApiCourseRepository(client: sl<FastApiClient>()));
  sl.registerLazySingleton(() => FastApiJobRepository(client: sl<FastApiClient>()));

  // Compat repos (what UI consumes)
  sl.registerLazySingleton<CourseRepository>(() => CourseRepositoryCompat(
    fastApi: sl<FastApiCourseRepository>(), supabase: sl<SupabaseCourseRepository>(),
  ));
  sl.registerLazySingleton<JobRepository>(() => JobRepositoryCompat(
    fastApi: sl<FastApiJobRepository>(), supabase: sl<SupabaseJobRepository>(),
  ));

  // BLoCs (factory = new per screen)
  sl.registerFactory(() => CourseListBloc(sl<CourseRepository>()));
  sl.registerFactory(() => CourseDetailBloc(sl<CourseRepository>()));
  sl.registerFactory(() => JobListBloc(sl<JobRepository>()));
  sl.registerFactory(() => JobDetailBloc(sl<JobRepository>()));
}
