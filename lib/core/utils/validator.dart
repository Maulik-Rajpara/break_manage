class Validator {
  static bool isPasswordStrong(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,20}$');
    return regex.hasMatch(password);
  }

  static String? passwordError(String password) {
    if (isPasswordStrong(password)) return null;
    return 'Password must be 8-20 chars, include upper, lower, special.';
  }
}