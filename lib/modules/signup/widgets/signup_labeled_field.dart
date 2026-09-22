import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/phone_code_prefix.dart';

class SignupLabeledField extends StatelessWidget {
  const SignupLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.inputFormatters,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.prefix,
    this.hintText,
    this.readOnly = false,
    this.fillColor,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final Widget? prefix;
  final String? hintText;
  final bool readOnly;
  final Color? fillColor;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: AppDimensions.fontXs,
          ),
        ),
        const SizedBox(height: 6),
        AppTextField(
          controller: controller,
          hintText:
              hintText ??
              (prefixIcon == null && prefix == null
                  ? AppStrings.fieldPlaceholder
                  : null),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          fillColor: fillColor ?? AppColors.fieldFill,
          borderColor: AppColors.fieldBorder,
          borderRadius: AppDimensions.radiusMedium,
          validator: validator,
          inputFormatters: inputFormatters,
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixIconConstraints,
          prefix: prefix,
          suffixIcon: suffixIcon,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          maxLines: maxLines,
          minLines: minLines,
          style: AppTextStyles.body.copyWith(
            color: AppColors.brandBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SignupPhoneField extends StatelessWidget {
  const SignupPhoneField({
    super.key,
    required this.controller,
    required this.validator,
    this.readOnly = false,
    this.fillColor,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool readOnly;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return SignupLabeledField(
      label: AppStrings.mobileNumber,
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: validator,
      readOnly: readOnly,
      hintText: AppStrings.fieldPlaceholder,
      fillColor: fillColor,
      prefix: const PhoneCodePrefix(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }
}
