import 'package:break_manage/features/question-steps/presentation/screen/question_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder imports for screens (replace with actual imports when screens are created)
import '../../features/onboard/presentation/screens/login_screen.dart';
import '../../features/onboard/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/question-screen',
      builder: (context, state) => const QuestionScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
); 