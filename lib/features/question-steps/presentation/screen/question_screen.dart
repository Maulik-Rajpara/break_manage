import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/colors.dart';
import '../provider/skills_provider.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/custom_radio.dart';
import '../widgets/custom_date_box.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/di/service_locator.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  Future<String?> _getUserId() async {
    final prefs = locator<PreferenceService>();
    return await prefs.getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: ChangeNotifierProvider(
        create: (_) => SkillsProvider(),
        child: Consumer<SkillsProvider>(
          builder: (context, provider, _) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Image.asset(AssetPath.backIcon, width: 22.sp, height:  22.sp),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              title: null,
              automaticallyImplyLeading: false,
              centerTitle: false,
              toolbarHeight: 56,
              // Remove shadow and divider
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PillProgressBar(
                    value: 0.3,
                    height: 8,
                    radius: 8,
                    filledColor: const Color(0xFF3030D6),
                    backgroundColor: const Color(0xFFD8DAE5),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primeTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tell us a bit more about yourself',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primeTextColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'How many of these tasks have you done before?\n(select all that apply)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primeTextColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 0,
                    childAspectRatio: 4.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: provider.allSkills.map((skill) {
                      final selected = provider.selectedSkills.contains(skill);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: CustomCheckbox(
                          value: selected,
                          onChanged: (_) => provider.toggleSkill(skill),
                          label: skill,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Do you have your own smartphone?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primeTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CustomRadio(
                        selected: provider.hasSmartphone == true,
                        onChanged: (val) => provider.setHasSmartphone(true),
                        label: 'Yes',
                      ),
                      const SizedBox(width: 24),
                      CustomRadio(
                        selected: provider.hasSmartphone == false,
                        onChanged: (val) => provider.setHasSmartphone(false),
                        label: 'No',
                      ),
                    ],
                  ),
                  if (provider.hasSmartphone == false) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Will you be able to get a phone for the job?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.primeTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CustomRadio(
                          selected: provider.canGetPhone == true,
                          onChanged: (val) => provider.setCanGetPhone(true),
                          label: 'Yes',
                        ),
                        const SizedBox(width: 24),
                        CustomRadio(
                          selected: provider.canGetPhone == false,
                          onChanged: (val) => provider.setCanGetPhone(false),
                          label: 'No',
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  const Text(
                    'Have you ever used google maps?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primeTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CustomRadio(
                        selected: provider.usedGoogleMaps == true,
                        onChanged: (val) => provider.setUsedGoogleMaps(true),
                        label: 'Yes',
                      ),
                      const SizedBox(width: 24),
                      CustomRadio(
                        selected: provider.usedGoogleMaps == false,
                        onChanged: (val) => provider.setUsedGoogleMaps(false),
                        label: 'No',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Date of birth',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primeTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CustomDateBox(
                        hint: 'DD',
                        value: provider.day,
                        maxLength: 2,
                        onChanged: provider.setDay,
                      ),
                      const SizedBox(width: 12),
                      CustomDateBox(
                        hint: 'MM',
                        value: provider.month,
                        maxLength: 2,
                        onChanged: provider.setMonth,
                      ),
                      const SizedBox(width: 12),
                      CustomDateBox(
                        hint: 'YYYY',
                        value: provider.year,
                        maxLength: 4,
                        onChanged: provider.setYear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: provider.isFormValid && !provider.loading
                          ? () async {
                              final userId = await _getUserId();
                              if (userId == null) return;
                              final success = await provider.saveOnboarding(userId);
                              if (success && context.mounted) {
                                context.go('/dashboard');
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isFormValid
                            ? AppColors.primaryColor
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
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
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final double radius;
  final Color filledColor;
  final Color backgroundColor;

  const _PillProgressBar({
    required this.value,
    required this.height,
    required this.radius,
    required this.filledColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: filledColor,
                  borderRadius: BorderRadius.circular(radius), // Both sides rounded
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
