import '../services/api_service.dart';

abstract class BaseRepository {
  const BaseRepository(this.apiService);

  final ApiService apiService;
}
