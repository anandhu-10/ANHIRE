import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/intro/splash_screen.dart';
import '../screens/intro/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/student_profile.dart';
import '../screens/student/resume_analyzer.dart';
import '../screens/student/aptitude_categories.dart';
import '../screens/student/aptitude_test_screen.dart';
import '../screens/student/interview_categories.dart';
import '../screens/student/mock_interview_screen.dart';
import '../screens/student/roadmap_screen.dart';
import '../screens/student/leaderboard_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_questions.dart';

final goRouterKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    navigatorKey: goRouterKey,
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isAuthenticating = authState.status == AuthStatus.authenticating;

      final loginLoc = state.namedLocation('login');
      final registerLoc = state.namedLocation('register');
      final forgotLoc = state.namedLocation('forgot-password');
      
      final goingToAuth = state.matchedLocation == loginLoc ||
          state.matchedLocation == registerLoc ||
          state.matchedLocation == forgotLoc;

      final goingToSplashOrOnboarding = state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      if (isAuthenticating) return null;

      // 1. Not logged in -> force login
      if (!isLoggedIn) {
        if (goingToSplashOrOnboarding || goingToAuth) return null;
        return '/login';
      }

      // 2. Logged in -> redirect if on Auth pages or Splash/Onboarding
      if (goingToAuth || goingToSplashOrOnboarding) {
        return authState.role == 'admin' ? '/admin-dashboard' : '/student-dashboard';
      }

      // 3. Prevent students from opening admin pages
      if (state.matchedLocation.startsWith('/admin-') && authState.role != 'admin') {
        return '/student-dashboard';
      }

      // 4. Prevent admins from opening student pages
      if ((state.matchedLocation.startsWith('/student-') ||
              state.matchedLocation == '/profile' ||
              state.matchedLocation == '/resume-analyzer' ||
              state.matchedLocation == '/aptitude' ||
              state.matchedLocation == '/mock-interview' ||
              state.matchedLocation == '/roadmap' ||
              state.matchedLocation == '/leaderboard') &&
          authState.role == 'admin') {
        return '/admin-dashboard';
      }

      return null;
    },
    routes: [
      // Splash and Onboarding
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'onboarding',
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: 'forgot-password',
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: 'verify',
        path: '/verify',
        builder: (context, state) => const VerificationScreen(),
      ),

      // Student Module Routes
      GoRoute(
        name: 'student-dashboard',
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
      GoRoute(
        name: 'resume-analyzer',
        path: '/resume-analyzer',
        builder: (context, state) => const ResumeAnalyzerScreen(),
      ),
      GoRoute(
        name: 'aptitude',
        path: '/aptitude',
        builder: (context, state) => const AptitudeCategoriesScreen(),
      ),
      GoRoute(
        name: 'aptitude-test',
        path: '/aptitude-test/:category/:difficulty',
        builder: (context, state) {
          final category = state.pathParameters['category'] ?? 'quantitative';
          final difficulty = state.pathParameters['difficulty'] ?? 'easy';
          return AptitudeTestScreen(category: category, difficulty: difficulty);
        },
      ),
      GoRoute(
        name: 'mock-interview',
        path: '/mock-interview',
        builder: (context, state) => const InterviewCategoriesScreen(),
      ),
      GoRoute(
        name: 'mock-interview-session',
        path: '/mock-interview-session/:type',
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'hr';
          return MockInterviewScreen(type: type);
        },
      ),
      GoRoute(
        name: 'roadmap',
        path: '/roadmap',
        builder: (context, state) => const RoadmapScreen(),
      ),
      GoRoute(
        name: 'leaderboard',
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),

      // Admin Module Routes
      GoRoute(
        name: 'admin-dashboard',
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        name: 'admin-questions',
        path: '/admin-questions',
        builder: (context, state) => const AdminQuestionsScreen(),
      ),
    ],
  );
});
