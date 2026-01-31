import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:silaju/features/splash/splash_screen.dart';
import 'package:silaju/features/onboarding/onboarding_screen.dart';
import 'package:silaju/features/auth/login_screen.dart';
import 'package:silaju/features/auth/register_screen.dart';
import 'package:silaju/features/home/home_screen.dart';
import 'package:silaju/features/report/create_report_screen.dart';
import 'package:silaju/features/report/report_history_screen.dart';
import 'package:silaju/features/report/report_detail_screen.dart';
import 'package:silaju/features/achievements/achievements_screen.dart';
import 'package:silaju/features/leaderboard/leaderboard_screen.dart';
import 'package:silaju/features/profile/profile_screen.dart';
import 'package:silaju/shared/widgets/main_shell.dart';

/// Route names for type-safe navigation
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = 'home';
  static const String achievements = 'achievements';
  static const String profile = 'profile';
  static const String createReport = '/report/create';
  static const String reportHistory = '/report/history';
  static const String reportDetail = '/report/:id';
  static const String leaderboard = '/leaderboard';
}

/// GoRouter configuration
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '${AppRoutes.main}/${AppRoutes.home}',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '${AppRoutes.main}/${AppRoutes.achievements}',
            builder: (context, state) => const AchievementsScreen(),
          ),
          GoRoute(
            path: '${AppRoutes.main}/${AppRoutes.profile}',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Create Report (full screen, outside shell)
      GoRoute(
        path: AppRoutes.createReport,
        builder: (context, state) => const CreateReportScreen(),
      ),

      // Report History
      GoRoute(
        path: AppRoutes.reportHistory,
        builder: (context, state) => const ReportHistoryScreen(),
      ),

      // Report Detail
      GoRoute(
        path: AppRoutes.reportDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ReportDetailScreen(reportId: id);
        },
      ),

      // Leaderboard
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
  );
}
