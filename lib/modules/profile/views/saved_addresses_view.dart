import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../../data/models/user_address.dart';
import '../controllers/saved_addresses_controller.dart';

class SavedAddressesView extends GetView<SavedAddressesController> {
  const SavedAddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            onPressed: controller.addAddress,
            backgroundColor: AppColors.brandBlack,
            foregroundColor: AppColors.white,
            elevation: 2,
            child: const Icon(Icons.add, color: AppColors.white, size: 28),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PillHeader(title: AppStrings.savedAddresses),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isPageLoading.value) {
                  return const AppPageLoader();
                }
                final items = controller.addresses;
                if (items.isEmpty) {
                  return const Center(
                    child: AppText(
                      text: AppStrings.noAddresses,
                      color: AppColors.tabInactive,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final address = items[index];
                    return _AddressCard(
                      address: address,
                      onEdit: () => controller.editAddress(address),
                      onDelete: () => controller.deleteAddress(address),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final UserAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.brandYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.brandBlack,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            text: address.displayName,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandBlack,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandBlack,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            text: address.labelTitle,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      text: address.address,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.tabInactive,
                      height: 1.4,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.tabInactive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
