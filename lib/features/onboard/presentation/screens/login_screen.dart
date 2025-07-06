import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/login_form.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../provider/login_provider.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/di/service_locator.dart';
// import 'package:get_it/get_it.dart'; // Uncomment if using get_it

// void setupServiceLocator() {
//   GetIt.I.registerLazySingleton<LoginProvider>(() => LoginProvider());
//   // Register other services here
// }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handlePostLogin(BuildContext context) async {
    final prefs = locator<PreferenceService>();
    final userService = locator<UserService>();
    final userId = await prefs.getUserId();
    if (userId == null) return;
    final onboarded = await userService.isUserOnboarded(userId);
    if (!mounted) return;
    if (onboarded) {
      context.go('/dashboard');
    } else {
      context.go('/question-screen');
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).viewInsets.bottom),
            child: LoginForm(onFormStateChanged: (bool isValid) {  },),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Consumer<LoginProvider>(
            builder: (context, provider, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppString.termsPrefix,
                      style: TextStyle(
                        color: AppColors.darkTextColor,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 2.sp),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        AppString.termsOfUse,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 13.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(AppString.and,
                        style: TextStyle(
                          color: AppColors.darkTextColor,
                          fontSize: 13.sp,
                        )),
                    SizedBox(width: 2.sp),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        AppString.privacyPolicy,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 13.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: provider.isFormValid && !provider.loading
                        ? () async {
                            final success = await provider.loginOrRegister();
                            if (success && mounted) {
                              await _handlePostLogin(context);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isEditing
                          ? AppColors.primaryColor
                          : AppColors.btnGreyColor,
                      foregroundColor: AppColors.whiteColor,
                      disabledBackgroundColor: AppColors.btnGreyColor,
                      disabledForegroundColor: AppColors.lightBtnTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: provider.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            AppString.continueBtn,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
