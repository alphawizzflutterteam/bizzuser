import 'package:get_storage/get_storage.dart';

class StorageKeys {
  StorageKeys._();

  static const String themeDark = 'theme_dark';
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userProfile = 'user_profile';
  static const String fcmToken = 'fcm_token';
  static const String uploadedFcmToken = 'uploaded_fcm_token';
}

class StorageService {
  StorageService({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  void write<T>(String key, T value) => _box.write(key, value);

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  bool has(String key) => _box.hasData(key);

  String? get accessToken => read<String>(StorageKeys.accessToken);

  bool get hasSession {
    final token = accessToken;
    return token != null && token.isNotEmpty;
  }

  void saveSession({required String token, required Map<String, dynamic> user}) {
    write(StorageKeys.accessToken, token);
    write(StorageKeys.userProfile, user);
  }

  void saveUser(Map<String, dynamic> user) {
    write(StorageKeys.userProfile, user);
  }

  Map<String, dynamic>? readUser() {
    final raw = _box.read(StorageKeys.userProfile);
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Future<void> clearSession() async {
    await remove(StorageKeys.accessToken);
    await remove(StorageKeys.refreshToken);
    await remove(StorageKeys.userProfile);
  }
}
