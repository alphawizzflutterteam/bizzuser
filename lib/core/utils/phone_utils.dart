class PhoneUtils {
  PhoneUtils._();

  static const String countryDigits = '91';
  static const String countryPrefix = '+91';

  static String toRequestPhone(String input) {
    final local = localNumber(input);
    return '$countryPrefix $local';
  }

  static String localNumber(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }
    if (digits.startsWith(countryDigits) && digits.length >= 12) {
      digits = digits.substring(digits.length - 10);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  static String toApiPhone(String input) {
    final local = localNumber(input);
    if (local.length == 10) {
      return '$countryDigits$local';
    }
    return local;
  }

  static String displayPhone(String input) {
    final local = localNumber(input);
    if (local.length != 10) {
      return input.trim();
    }
    return '$countryPrefix ${local.substring(0, 5)} ${local.substring(5)}';
  }

  static bool isSameNumber(String left, String right) {
    return localNumber(left) == localNumber(right);
  }
}
