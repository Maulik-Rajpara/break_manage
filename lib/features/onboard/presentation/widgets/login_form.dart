import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_strings.dart';
import 'custom_text_field.dart';
import 'custom_circle_checkbox.dart';
import '../provider/login_provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required void Function(bool isValid) onFormStateChanged});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _referralController;
  late final FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _referralController = TextEditingController();
    _passwordFocusNode = FocusNode();
    _passwordFocusNode.addListener(() {
      final provider = context.read<LoginProvider>();
      provider.setPasswordFieldFocused(_passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.sp),
              Text(
                AppString.loginTitle,
                style: TextStyle(
                  color: AppColors.primeTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 32),
              CustomTextField(
                controller: _usernameController,
                hint: AppString.usernameHint,
                onChanged: (val) {
                  provider.setUsername(val);
                },
              ),
              SizedBox(height: 18.sp),
              CustomTextField(
                controller: _passwordController,
                hint: AppString.passwordHint,
                obscureText: !provider.showPassword,
                onChanged: (val) {
                  provider.setPassword(val);
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    provider.showPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textHintColor,
                  ),
                  onPressed: provider.toggleShowPassword,
                ),
                focusNode: _passwordFocusNode,
                borderColor: provider.passwordFieldFocused
                    ? AppColors.primaryColor
                    : AppColors.textHintColor,
              ),
              if (provider.passwordError != null && !provider.isPasswordStrong)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    provider.passwordError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(height: 18.sp),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomCircleCheckbox(
                    value: provider.hasReferral,
                    onChanged: provider.setHasReferral,
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => provider.setHasReferral(!provider.hasReferral),
                    child: Text(
                      AppString.referralCheckbox,
                      style: TextStyle(
                        color: provider.hasReferral
                            ? AppColors.primaryColor
                            : AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.sp),
              if (provider.hasReferral)
                CustomTextField(
                  controller: _referralController,
                  hint: AppString.referralHint,
                  onChanged: (val) {
                    provider.setReferral(val);
                  },
                  keyboardType: TextInputType.number,
                ),
              if (provider.referralError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    provider.referralError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
} 