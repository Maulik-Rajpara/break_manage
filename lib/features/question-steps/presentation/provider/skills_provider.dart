import 'package:flutter/material.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/di/service_locator.dart';

class SkillsProvider extends ChangeNotifier {
  // Skills/tasks
  final List<String> allSkills = [
    'Cutting vegetables',
    'Sweeping',
    'Mopping',
    'Cleaning bathrooms',
    'Laundry',
    'Washing dishes',
    'None of the above',
  ];
  final Set<String> selectedSkills = {};

  // Smartphone question
  bool? hasSmartphone;
  // If no smartphone
  bool? canGetPhone;
  // Google Maps question
  bool? usedGoogleMaps;

  // Date of birth
  String day = '';
  String month = '';
  String year = '';

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  void toggleSkill(String skill) {
    if (skill == 'None of the above') {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        selectedSkills.clear();
        selectedSkills.add(skill);
      }
    } else {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        selectedSkills.remove('None of the above');
        selectedSkills.add(skill);
      }
    }
    notifyListeners();
  }

  void setHasSmartphone(bool value) {
    hasSmartphone = value;
    if (value) canGetPhone = null;
    notifyListeners();
  }

  void setCanGetPhone(bool value) {
    canGetPhone = value;
    notifyListeners();
  }

  void setUsedGoogleMaps(bool value) {
    usedGoogleMaps = value;
    notifyListeners();
  }

  void setDay(String value) {
    day = value;
    notifyListeners();
  }

  void setMonth(String value) {
    month = value;
    notifyListeners();
  }

  void setYear(String value) {
    year = value;
    notifyListeners();
  }

  bool get isFormValid {
    // Add your validation logic here
    return selectedSkills.isNotEmpty &&
        hasSmartphone != null &&
        (hasSmartphone! ? true : canGetPhone != null) &&
        usedGoogleMaps != null &&
        day.length == 2 && month.length == 2 && year.length == 4;
  }

  Future<bool> saveOnboarding(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final onboardingService = locator<OnboardingService>();
    final userService = locator<UserService>();
    try {
      final birthDate = '$day-$month-$year';
      await onboardingService.saveOnboardingData(
        userId: userId,
        tasks: selectedSkills.toList(),
        hasSmartphone: hasSmartphone!,
        canGetPhone: canGetPhone,
        usedGoogleMap: usedGoogleMaps!,
        birthDate: birthDate,
      );
      await userService.setUserOnboarded(userId, true);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
} 