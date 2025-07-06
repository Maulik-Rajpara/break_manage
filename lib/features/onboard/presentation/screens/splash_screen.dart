import 'package:break_manage/core/constants/app_strings.dart';
import 'package:break_manage/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/di/service_locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    final prefs = locator<PreferenceService>();
    final userService = locator<UserService>();
    final userId = await prefs.getUserId();
    await Future.delayed(Duration(seconds: 2));
    if (userId == null) {
      if (mounted) context.go('/login');
      return;
    }
    final onboarded = await userService.isUserOnboarded(userId);
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      if (onboarded) {
        context.go('/dashboard');
      } else {
        context.go('/question-screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPath.appLogo,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                AppString.appTitle,
                style: TextStyle(
                  color: AppColors.primeTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
