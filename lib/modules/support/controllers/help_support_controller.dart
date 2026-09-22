import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/support_ticket.dart';
import '../../../data/repositories/support_catalog.dart';
import '../../../data/repositories/support_repository.dart';

class HelpSupportController extends GetxController with PageLoadingMixin {
  final tickets = <SupportTicket>[...SupportCatalog.tickets].obs;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    loadTickets();
  }

  Future<void> loadTickets() async {
    if (!Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final items = await Get.find<SupportRepository>().fetchTickets();
      tickets.assignAll(items);
    });
  }

  void openChat(SupportTicket ticket) {
    Get.toNamed(AppRoutes.supportTicketChat, arguments: ticket);
  }

  void addTicket() {
    Get.toNamed(AppRoutes.addSupportTicket);
  }
}
