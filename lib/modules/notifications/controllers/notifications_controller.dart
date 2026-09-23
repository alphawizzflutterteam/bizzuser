import 'package:get/get.dart';

import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/safety_catalog.dart';
import '../../home/controllers/home_controller.dart';

class NotificationsController extends GetxController with PageLoadingMixin {
  /// Starts empty (page loader) – filled from `GET /user/notifications`.
  final items = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final isMarkingAll = false.obs;

  bool get hasUnread => items.any((item) => !item.read);

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<NotificationRepository>()) {
      // Offline demo mode only.
      items.assignAll(SafetyCatalog.notifications);
      _recount();
      stopPageLoading();
      return;
    }
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (!Get.isRegistered<NotificationRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final feed = await Get.find<NotificationRepository>().fetchNotifications();
      items.assignAll(feed.items);
      // Server `unreadCount` is per user (broadcasts included).
      unreadCount.value = feed.unreadCount;
      _syncHomeBadge();
    });
  }

  /// Marks [item] read optimistically; reverts only if the request fails.
  Future<void> openItem(AppNotification item) async {
    if (item.id.isEmpty || item.read) return;
    if (!Get.isRegistered<NotificationRepository>()) return;
    _setRead(item.id, true);
    try {
      await Get.find<NotificationRepository>().markRead(item.id);
    } catch (_) {
      _setRead(item.id, false);
    }
  }

  Future<void> markAllRead() async {
    if (isMarkingAll.value || !hasUnread) return;
    if (!Get.isRegistered<NotificationRepository>()) return;
    final before = items.toList(growable: false);
    final unreadBefore = unreadCount.value;
    isMarkingAll.value = true;
    items.assignAll(before.map((item) => item.copyWith(read: true)));
    unreadCount.value = 0;
    _syncHomeBadge();
    try {
      await Get.find<NotificationRepository>().markAllRead();
    } catch (_) {
      items.assignAll(before);
      unreadCount.value = unreadBefore;
      _syncHomeBadge();
    } finally {
      isMarkingAll.value = false;
    }
  }

  void _setRead(String id, bool read) {
    final index = items.indexWhere((entry) => entry.id == id);
    if (index < 0) return;
    items[index] = items[index].copyWith(read: read);
    final delta = read ? -1 : 1;
    final next = unreadCount.value + delta;
    unreadCount.value = next < 0 ? 0 : next;
    _syncHomeBadge();
  }

  void _recount() {
    unreadCount.value = items.where((item) => !item.read).length;
  }

  void _syncHomeBadge() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().unreadCount.value = unreadCount.value;
    }
  }
}
