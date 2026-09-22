import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/verify_otp_controller.dart';

class OtpInputRow extends GetView<VerifyOtpController> {
  const OtpInputRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(controller.otpControllers.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == controller.otpControllers.length - 1
                  ? 0
                  : AppDimensions.paddingSmall,
            ),
            child: _OtpBox(index: index),
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({required this.index});

  final int index;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  late final VerifyOtpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<VerifyOtpController>();
    _controller.otpControllers[widget.index].addListener(_rebuild);
    _controller.focusNodes[widget.index].addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.otpControllers[widget.index].removeListener(_rebuild);
    _controller.focusNodes[widget.index].removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _controller.otpControllers[widget.index].text.isNotEmpty;
    final isFocused = _controller.focusNodes[widget.index].hasFocus;
    final borderColor = (hasValue || isFocused)
        ? AppColors.brandYellow
        : AppColors.fieldBorder;

    return SizedBox(
      height: AppDimensions.otpBoxSize,
      child: TextField(
        controller: _controller.otpControllers[widget.index],
        focusNode: _controller.focusNodes[widget.index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        cursorColor: AppColors.brandBlack,
        style: AppTextStyles.title.copyWith(
          color: AppColors.brandBlack,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: AppStrings.otpHintDash,
          hintStyle: AppTextStyles.title.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: AppColors.fieldFill,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: const BorderSide(
              color: AppColors.brandYellow,
              width: 1.6,
            ),
          ),
        ),
        onChanged: (value) => _controller.onDigitChanged(widget.index, value),
      ),
    );
  }
}
