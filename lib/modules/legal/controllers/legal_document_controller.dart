import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/legal_content.dart';
import '../../../data/repositories/cms_repository.dart';
import '../../../data/repositories/legal_catalog.dart';

class LegalDocumentController extends GetxController with PageLoadingMixin {
  LegalDocumentController({
    required this.slug,
    required this.fallbackTitle,
  });

  final String slug;
  final String fallbackTitle;

  final title = ''.obs;
  final updatedOn = AppStrings.updatedOn.obs;
  final intro = AppStrings.legalIntro.obs;
  final sections = <LegalSection>[...LegalCatalog.sections].obs;

  @override
  void onInit() {
    super.onInit();
    title.value = fallbackTitle;
    if (!Get.isRegistered<CmsRepository>()) {
      stopPageLoading();
      return;
    }
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (!Get.isRegistered<CmsRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final page = await Get.find<CmsRepository>().fetchPage(slug);
      if (page.title.isNotEmpty) {
        title.value = page.title;
      }
      if (page.updatedAt.isNotEmpty) {
        updatedOn.value = DateFormatUtils.updatedOn(
          page.updatedAt,
          fallback: AppStrings.updatedOn,
        );
      }
      if (page.content.isNotEmpty) {
        intro.value = page.content;
        sections.clear();
      }
    });
  }
}
