import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/utils/page_loading_mixin.dart';
import '../../../data/models/user_address.dart';
import '../../../data/repositories/address_catalog.dart';
import '../../../data/repositories/address_repository.dart';

class SavedAddressesController extends GetxController with PageLoadingMixin {
  final addresses = <UserAddress>[...AddressCatalog.addresses].obs;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<AddressRepository>()) {
      stopPageLoading();
      return;
    }
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    if (!Get.isRegistered<AddressRepository>()) {
      stopPageLoading();
      return;
    }
    await runPageLoad(() async {
      final items = await Get.find<AddressRepository>().fetchAddresses();
      addresses.assignAll(items);
    });
  }

  void addAddress() {
    Get.toNamed(AppRoutes.addressForm);
  }

  void editAddress(UserAddress address) {
    Get.toNamed(AppRoutes.addressForm, arguments: address);
  }

  Future<void> deleteAddress(UserAddress address) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.deleteAddress,
      message: AppStrings.deleteAddressConfirm,
    );
    if (confirmed != true) return;

    if (!Get.isRegistered<AddressRepository>() || address.id.isEmpty) {
      addresses.removeWhere((item) => item.id == address.id);
      AppUtils.showSuccess(AppStrings.addressDeleted);
      return;
    }

    final message = await runApi(
      () => Get.find<AddressRepository>().deleteAddress(address.id),
    );
    if (message == null) return;
    addresses.removeWhere((item) => item.id == address.id);
    AppUtils.showSuccess(
      message.isNotEmpty ? message : AppStrings.addressDeleted,
    );
  }
}
