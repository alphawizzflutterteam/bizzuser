import '../constants/app_strings.dart';

class AppValidators {
  AppValidators._();

  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? AppStrings.requiredField;
    }
    return null;
  }

  /// Trims and collapses inner whitespace ("  Ravi   Kumar " → "Ravi Kumar").
  static String normalizeName(String? value) {
    return (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 3–30 characters; letters (any script), spaces and . ' - only,
  /// starting with a letter. Mirrors the backend rule.
  static String? name(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    final normalized = normalizeName(value);
    if (normalized.length < 3 || normalized.length > 30) {
      return AppStrings.nameLength;
    }
    final pattern = RegExp(r"^[\p{L}][\p{L}\s.'-]*$", unicode: true);
    if (!pattern.hasMatch(normalized)) {
      return AppStrings.nameCharacters;
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;

    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(value!)) {
      return AppStrings.invalidPassword;
    }
    return null;
  }

  static String? phone(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;

    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return email(value);
  }

  static String? otp(String? value, {int length = 4}) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;

    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length != length) {
      return AppStrings.invalidOtp;
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;

    if (value != original) {
      return AppStrings.passwordMismatch;
    }
    return null;
  }
}
