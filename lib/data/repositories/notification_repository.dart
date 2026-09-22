import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/app_notification.dart';
import 'base_repository.dart';

class NotificationRepository extends BaseRepository {
  const NotificationRepository(super.apiService);

  Future<NotificationFeed> fetchNotifications() async {
    final json = await apiService.getJson(ApiConstants.notifications);
    final map = ApiBody.dataMap(json);
    final items = ApiBody.asMapList(map['items'])
        .map(AppNotification.fromJson)
        .toList(growable: false);
    return NotificationFeed(
      unreadCount: ApiBody.asInt(map['unreadCount']) ??
          items.where((item) => !item.read).length,
      items: items,
    );
  }

  Future<AppNotification> markRead(String id) async {
    final json = await apiService.patchJson(ApiConstants.notificationRead(id));
    final map = ApiBody.dataMap(json);
    return AppNotification.fromJson(map.isEmpty ? json : map);
  }
}
