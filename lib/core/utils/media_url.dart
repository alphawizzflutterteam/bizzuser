import '../constants/api_constants.dart';

class MediaUrl {
  MediaUrl._();

  static String resolve(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('file:') ||
        trimmed.contains('\\') ||
        (trimmed.length > 1 && trimmed[1] == ':')) {
      return trimmed;
    }
    final origin = ApiConstants.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }
    return '$origin/$trimmed';
  }

  static bool isRemote(String path) {
    final trimmed = path.trim();
    return trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('/');
  }
}
