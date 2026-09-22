import 'package:get/get.dart';

import '../../../core/utils/page_loading_mixin.dart';
import '../../../core/utils/run_api.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/safety_catalog.dart';
import '../../home/controllers/home_controller.dart';

class NotificationsController extends GetxController with PageLoadingMixin {
  final items = <AppNotification>[...SafetyCatalog.notifications].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    unreadCount.value = items.where((item) => !item.read).length;
    if (!Get.isRegistered<NotificationRepository>()) {
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
      unreadCount.value = feed.unreadCount;
      _syncHomeBadge();
    });
  }

  Future<void> openItem(AppNotification item) async {
    if (item.id.isEmpty || item.read) return;
    if (!Get.isRegistered<NotificationRepository>()) return;
    final result = await runApi(
      () => Get.find<NotificationRepository>().markRead(item.id),
    );
    if (result == null) return;
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(read: true);
    }
    unreadCount.value = items.where((entry) => !entry.read).length;
    _syncHomeBadge();
  }

  void _syncHomeBadge() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().unreadCount.value = unreadCount.value;
    }
  }
}
