class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String jobs = '/jobs';
  static const String aiCopilot = '/ai-copilot';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Relative sub-routes
  static const String courseDetail = 'detail/:courseId';
  static const String jobDetail = 'detail/:jobId';
  static const String savedJobs = 'saved';
  static const String appliedJobs = 'applied';
  static const String editProfile = 'edit';
  static const String settings = 'settings';

  static String courseDetailPath(String id) => '/courses/detail/$id';
  static String jobDetailPath(String id) => '/jobs/detail/$id';
}
