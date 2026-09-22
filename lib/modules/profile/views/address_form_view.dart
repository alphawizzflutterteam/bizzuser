import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../signup/widgets/signup_labeled_field.dart';
import '../controllers/address_form_controller.dart';

class AddressFormView extends GetView<AddressFormController> {
  const AddressFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CreamWashScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: PillHeader(title: controller.title),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    if (!controller.isLocationPick) ...[
                      _MapPicker(controller: controller),
                      const SizedBox(height: 14),
                    ],
                    SignupLabeledField(
                      label: AppStrings.searchAddressHint,
                      controller: controller.searchController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.search,
                      fillColor: AppColors.white,
                      hintText: AppStrings.searchAddressHint,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.tabInactive,
                      ),
                      onChanged: controller.onSearchChanged,
                    ),
                    Obx(() {
                      if (controller.isSearchingPlaces.value &&
                          controller.suggestions.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: SizedBox(height: 40, child: AppPageLoader()),
                        );
                      }
                      if (controller.suggestions.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                          border: Border.all(color: AppColors.fieldBorder),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.suggestions.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: AppColors.fieldBorder,
                          ),
                          itemBuilder: (context, index) {
                            final item = controller.suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.brandYellow,
                              ),
                              title: AppText(
                                text: item.mainText.isNotEmpty
                                    ? item.mainText
                                    : item.description,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                              ),
                              subtitle: item.secondaryText.isEmpty
                                  ? null
                                  : AppText(
                                      text: item.secondaryText,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                    ),
                              onTap: () => controller.selectSuggestion(item),
                            );
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                    if (!controller.isLocationPick) ...[
                      SignupLabeledField(
                        label: AppStrings.addressLabel,
                        controller: controller.labelController,
                        readOnly: true,
                        fillColor: AppColors.white,
                        onTap: controller.openLabelPicker,
                        suffixIcon: const IgnorePointer(
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.tabInactive,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SignupLabeledField(
                        label: AppStrings.addressName,
                        controller: controller.nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        fillColor: AppColors.white,
                      ),
                      const SizedBox(height: 14),
                    ],
                    SignupLabeledField(
                      label: AppStrings.addressLine,
                      controller: controller.addressController,
                      readOnly: true,
                      fillColor: AppColors.white,
                      maxLines: 3,
                      minLines: 2,
                      hintText: AppStrings.pickOnMap,
                      suffixIcon: Obx(
                        () => controller.isResolvingAddress.value
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.brandYellow,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.my_location_rounded,
                                color: AppColors.brandYellow,
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Obx(
                      () => AppButton(
                        title: controller.saveButtonTitle,
                        isLoading: controller.isLoading.value,
                        backgroundColor: AppColors.brandBlack,
                        textColor: AppColors.white,
                        borderRadius: 28,
                        height: 52,
                        onPressed: controller.save,
                      ),
                    ),
                    SizedBox(height: bottomInset),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPicker extends StatelessWidget {
  const _MapPicker({required this.controller});

  final AddressFormController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (controller.canShowMap)
              GoogleMap(
                initialCameraPosition: controller.initialCamera,
                onMapCreated: controller.onMapCreated,
                onCameraMove: controller.onCameraMove,
                onCameraIdle: controller.onCameraIdle,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: false,
              )
            else
              ColoredBox(
                color: AppColors.mapLand,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        size: 42,
                        color: AppColors.brandYellow,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        text: AppStrings.pickOnMap,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const IgnorePointer(
              child: Icon(
                Icons.location_on_rounded,
                size: 42,
                color: AppColors.brandYellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
