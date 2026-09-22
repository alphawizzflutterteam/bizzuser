import '../../core/constants/api_constants.dart';
import '../models/app_config.dart';
import 'base_repository.dart';

class AppConfigRepository extends BaseRepository {
  AppConfigRepository(super.apiService);

  AppConfig? _cached;

  AppConfig? get cached => _cached;

  Future<AppConfig> fetch({bool force = false}) async {
    if (!force && _cached != null) return _cached!;
    final json = await apiService.getJson(ApiConstants.appConfig);
    _cached = AppConfig.fromJson(json);
    return _cached!;
  }
}
