import 'package:get/get.dart';

mixin PageLoadingMixin on GetxController {
  final isPageLoading = true.obs;

  void stopPageLoading() {
    isPageLoading.value = false;
  }

  Future<void> runPageLoad(Future<void> Function() request) async {
    isPageLoading.value = true;
    try {
      await request();
    } catch (_) {
    } finally {
      isPageLoading.value = false;
    }
  }
}
