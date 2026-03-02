import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../../blocs/course/course_list_bloc.dart';
import '../../blocs/course/course_detail_bloc.dart';
import '../../blocs/job/job_list_bloc.dart';
import '../../blocs/job/job_detail_bloc.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/courses/presentation/pages/course_list_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/jobs/presentation/pages/job_list_page.dart';
import '../../features/jobs/presentation/pages/job_detail_page.dart';
import '../../features/jobs/presentation/pages/saved_jobs_page.dart';
import '../../features/jobs/presentation/pages/applied_jobs_page.dart';
import '../../features/ai_copilot/presentation/pages/ai_copilot_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _coursesKey = GlobalKey<NavigatorState>(debugLabel: 'courses');
  static final _jobsKey = GlobalKey<NavigatorState>(debugLabel: 'jobs');
  static final _aiKey = GlobalKey<NavigatorState>(debugLabel: 'ai');
  static final _profileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      // Placeholder: when auth is implemented, check token here.
      // For now, allow all routes. Uncomment below when auth is ready:
      // final loggedIn = sl<TokenStorage>().hasToken;
      // final onAuthPage = state.matchedLocation == AppRoutes.login ||
      //     state.matchedLocation == AppRoutes.onboarding ||
      //     state.matchedLocation == AppRoutes.splash;
      // if (!loggedIn && !onAuthPage) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingPage()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: AppRoutes.notifications, parentNavigatorKey: _rootKey, builder: (_, __) => const NotificationsPage()),

      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootKey,
        builder: (_, __, shell) => MainShellPage(navigationShell: shell),
        branches: [
          StatefulShellBranch(navigatorKey: _homeKey, routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
          ]),
          StatefulShellBranch(navigatorKey: _coursesKey, routes: [
            GoRoute(
              path: AppRoutes.courses,
              builder: (_, __) => BlocProvider(create: (_) => sl<CourseListBloc>()..add(const CourseListFetched()), child: const CourseListPage()),
              routes: [
                GoRoute(path: AppRoutes.courseDetail, parentNavigatorKey: _rootKey, builder: (_, state) {
                  final id = state.pathParameters['courseId']!;
                  return BlocProvider(create: (_) => sl<CourseDetailBloc>()..add(CourseDetailFetched(id)), child: CourseDetailPage(courseId: id));
                }),
              ],
            ),
          ]),
          StatefulShellBranch(navigatorKey: _jobsKey, routes: [
            GoRoute(
              path: AppRoutes.jobs,
              builder: (_, __) => BlocProvider(create: (_) => sl<JobListBloc>()..add(const JobListFetched()), child: const JobListPage()),
              routes: [
                GoRoute(path: AppRoutes.jobDetail, parentNavigatorKey: _rootKey, builder: (_, state) {
                  final id = state.pathParameters['jobId']!;
                  return BlocProvider(create: (_) => sl<JobDetailBloc>()..add(JobDetailFetched(id)), child: JobDetailPage(jobId: id));
                }),
                GoRoute(path: AppRoutes.savedJobs, builder: (_, __) => const SavedJobsPage()),
                GoRoute(path: AppRoutes.appliedJobs, builder: (_, __) => const AppliedJobsPage()),
              ],
            ),
          ]),
          StatefulShellBranch(navigatorKey: _aiKey, routes: [
            GoRoute(path: AppRoutes.aiCopilot, builder: (_, __) => const AiCopilotPage()),
          ]),
          StatefulShellBranch(navigatorKey: _profileKey, routes: [
            GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfilePage(), routes: [
              GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsPage()),
            ]),
          ]),
        ],
      ),
    ],
  );
}
