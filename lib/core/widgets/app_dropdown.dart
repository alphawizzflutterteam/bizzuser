import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.hint,
    this.label,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.isExpanded = true,
    this.itemToString,
    this.itemBuilder,
    this.fillColor,
    this.borderRadius,
  });

  final List<T> items;
  final T? selectedValue;
  final String? hint;
  final String? label;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool enabled;
  final bool isExpanded;
  final String Function(T)? itemToString;
  final Widget Function(T)? itemBuilder;
  final Color? fillColor;
  final double? borderRadius;

  String _labelFor(T item) => itemToString?.call(item) ?? item.toString();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      borderRadius ?? AppDimensions.radiusMedium,
    );

    return DropdownButtonFormField<T>(
      key: ValueKey(selectedValue),
      initialValue: items.contains(selectedValue) ? selectedValue : null,
      isExpanded: isExpanded,
      hint: hint != null ? Text(hint!) : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: itemBuilder?.call(item) ?? Text(_labelFor(item)),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownColor: Theme.of(context).cardTheme.color ?? AppColors.surface,
      borderRadius: radius,
    );
  }
}
