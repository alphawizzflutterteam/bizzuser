import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_text_field.dart';

class AddAmountDialog extends StatefulWidget {
  const AddAmountDialog({super.key});

  static Future<num?> show() {
    return Get.dialog<num>(
      const AddAmountDialog(),
      barrierDismissible: false,
    );
  }

  @override
  State<AddAmountDialog> createState() => _AddAmountDialogState();
}

class _AddAmountDialogState extends State<AddAmountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    AppUtils.hideKeyboard();
    final amount = num.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) {
      AppUtils.showError(AppStrings.invalidAmount);
      return;
    }
    Get.back(result: amount);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(text: AppStrings.addAmount, style: AppTextStyles.title),
            const SizedBox(height: AppDimensions.paddingSmall),
            AppTextField(
              controller: _controller,
              hintText: AppStrings.enterAmount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: AppStrings.cancel,
                    backgroundColor: AppColors.greyLight,
                    textColor: AppColors.textPrimary,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Expanded(
                  child: AppButton(
                    title: AppStrings.addAmount,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
