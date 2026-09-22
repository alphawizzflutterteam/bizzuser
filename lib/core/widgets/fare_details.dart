import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../utils/app_utils.dart';
import 'app_card.dart';
import 'app_text.dart';

class FareDetailsCard extends StatelessWidget {
  const FareDetailsCard({
    super.key,
    required this.baseFare,
    required this.gst,
    required this.total,
    this.discount = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.distanceFare = 0,
    this.waitingCharge = 0,
    this.showIcon = false,
  });

  final double baseFare;
  final double gst;
  final double total;
  final double discount;
  final double cgst;
  final double sgst;
  final double igst;
  final double distanceFare;
  final double waitingCharge;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showIcon) ...[
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.brandBlack,
                  size: AppDimensions.iconSize,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
              ],
              AppText(
                text: AppStrings.fareDetails,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          FareRow(
            label: AppStrings.baseFare,
            value: AppUtils.rupee(baseFare, decimals: true),
          ),
          if (distanceFare > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            FareRow(
              label: AppStrings.distanceFare,
              value: AppUtils.rupee(distanceFare, decimals: true),
            ),
          ],
          if (waitingCharge > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            FareRow(
              label: AppStrings.waitingCharge,
              value: AppUtils.rupee(waitingCharge, decimals: true),
            ),
          ],
          if (gst > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            FareRow(
              label: AppStrings.tax,
              value: AppUtils.rupee(gst, decimals: true),
            ),
          ],
          if (cgst > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            FareRow(
              label: AppStrings.cgst,
              value: AppUtils.rupee(cgst, decimals: true),
            ),
          ],
          if (sgst > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            FareRow(
              label: AppStrings.sgst,
              value: AppUtils.rupee(sgst, decimals: true),
            ),
          ],
          if (igst > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            FareRow(
              label: AppStrings.igst,
              value: AppUtils.rupee(igst, decimals: true),
            ),
          ],
          if (discount > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            FareRow(
              label: AppStrings.couponAppliedLabel,
              value: '- ${AppUtils.rupee(discount, decimals: true)}',
              valueColor: AppColors.couponGreen,
            ),
          ],
          const Divider(height: 24),
          FareRow(
            label: AppStrings.totalAmount,
            value: AppUtils.rupee(total, decimals: true),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class FareRow extends StatelessWidget {
  const FareRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.body.copyWith(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Row(
      children: [
        Expanded(
          child: AppText(text: label, style: style),
        ),
        AppText(
          text: value,
          style: style.copyWith(color: valueColor ?? AppColors.brandBlack),
        ),
      ],
    );
  }
}
