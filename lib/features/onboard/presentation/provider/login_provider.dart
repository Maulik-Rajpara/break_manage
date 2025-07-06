import 'package:flutter/material.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/preference_service.dart';

class LoginProvider extends ChangeNotifier {
  String _username = '';
  String _password = '';
  String _referral = '';
  bool _hasReferral = false;
  bool _showPassword = false;
  bool _passwordFieldFocused = false;
  bool _hasPasswordInteracted = false;

  bool _loading = false;
  String? _error;

  String get username => _username;
  String get password => _password;
  String get referral => _referral;
  bool get hasReferral => _hasReferral;
  bool get showPassword => _showPassword;
  bool get passwordFieldFocused => _passwordFieldFocused;
  bool get hasPasswordInteracted => _hasPasswordInteracted;
  bool get loading => _loading;
  String? get error => _error;

  bool get isFormValid =>
      _username.isNotEmpty &&
      Validator.isPasswordStrong(_password) &&
      (!_hasReferral || _referral.isNotEmpty);

  bool get isEditing => _username.isNotEmpty || _password.isNotEmpty;

  bool get isPasswordStrong => Validator.isPasswordStrong(_password);
  String? get passwordError => hasPasswordInteracted ? Validator.passwordError(_password) : null;

  String? get referralError {
    if (_hasReferral && _referral.isEmpty) {
      return 'Please enter a referral code or uncheck the box.';
    }
    return null;
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    if (!_hasPasswordInteracted && value.isNotEmpty) {
      _hasPasswordInteracted = true;
    }
    notifyListeners();
  }

  void setReferral(String value) {
    _referral = value;
    notifyListeners();
  }

  void setHasReferral(bool value) {
    _hasReferral = value;
    if (!value) _referral = '';
    notifyListeners();
  }

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void setPasswordFieldFocused(bool focused) {
    _passwordFieldFocused = focused;
    notifyListeners();
  }

  void clear() {
    _username = '';
    _password = '';
    _referral = '';
    _hasReferral = false;
    _showPassword = false;
    _passwordFieldFocused = false;
    _hasPasswordInteracted = false;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> loginOrRegister() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final userService = locator<UserService>();
    final prefs = locator<PreferenceService>();
    try {
      final exists = await userService.userExists(_username);
      if (exists) {
        final valid = await userService.validateUser(_username, _password);
        if (!valid) {
          _error = 'Invalid username or password.';
          _loading = false;
          notifyListeners();
          return false;
        }
      } else {
        await userService.registerUser(_username, _password, referral: _referral);
      }
      final userId = await userService.getUserIdByUsername(_username);
      if (userId != null) {
        await prefs.setUserId(userId);
      }
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