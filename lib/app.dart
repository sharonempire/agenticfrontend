import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/utils/auth_session.dart';
import 'core/utils/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TokenStorage _tokenStorage;
  late final AuthSession _authSession;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final DashboardRepository _dashboardRepository;
  late final AuthProvider _authProvider;
  late final DashboardProvider _dashboardProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _tokenStorage = const TokenStorage();
    _authSession = AuthSession();
    _apiClient = ApiClient(
      tokenStorage: _tokenStorage,
      authSession: _authSession,
    );

    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(apiClient: _apiClient),
      tokenStorage: _tokenStorage,
    );
    _dashboardRepository = DashboardRepositoryImpl(
      remoteDataSource: DashboardRemoteDataSourceImpl(apiClient: _apiClient),
    );

    _authProvider = AuthProvider(
      repository: _authRepository,
      authSession: _authSession,
    );
    _dashboardProvider = DashboardProvider(
      repository: _dashboardRepository,
      authProvider: _authProvider,
    );

    _router = GoRouter(
      initialLocation: SplashScreen.routePath,
      refreshListenable: _authProvider,
      redirect: (_, state) {
        final location = state.matchedLocation;
        final onSplash = location == SplashScreen.routePath;
        final onAuth =
            location == LoginScreen.routePath ||
            location == RegisterScreen.routePath;

        if (!_authProvider.isInitialized) {
          return onSplash ? null : SplashScreen.routePath;
        }

        if (!_authProvider.isAuthenticated) {
          return onAuth ? null : LoginScreen.routePath;
        }

        if (onAuth || onSplash) {
          return DashboardScreen.routePath;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: SplashScreen.routePath,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: LoginScreen.routePath,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: RegisterScreen.routePath,
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: DashboardScreen.routePath,
          builder: (_, __) => const DashboardScreen(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _dashboardProvider.dispose();
    _authProvider.dispose();
    _apiClient.dispose();
    _authSession.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<DashboardProvider>.value(
          value: _dashboardProvider,
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF7F8FC),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
