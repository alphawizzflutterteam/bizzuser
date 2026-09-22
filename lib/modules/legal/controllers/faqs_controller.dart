import 'package:get/get.dart';

import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/legal_content.dart';
import '../../../data/repositories/legal_catalog.dart';
import '../../../data/repositories/support_repository.dart';

class FaqsController extends GetxController with PageLoadingMixin {
  final expandedIndex = 0.obs;
  final items = <FaqItem>[...LegalCatalog.faqs].obs;

  void toggle(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    if (!Get.isRegistered<SupportRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final faqs = await Get.find<SupportRepository>().fetchFaqs();
      if (faqs.isNotEmpty) {
        items.assignAll(faqs);
      }
    });
  }
}
