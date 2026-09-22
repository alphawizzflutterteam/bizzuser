import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  static Size size(BuildContext context) => MediaQuery.sizeOf(context);

  static double width(BuildContext context) => size(context).width;

  static double height(BuildContext context) => size(context).height;

  static bool isMobile(BuildContext context) =>
      width(context) < AppDimensions.tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = width(context);
    return w >= AppDimensions.tabletBreakpoint &&
        w < AppDimensions.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      width(context) >= AppDimensions.desktopBreakpoint;

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context) || isTablet(context)) {
      return AppDimensions.maxContentWidthTablet;
    }
    return AppDimensions.maxContentWidth;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppDimensions.paddingMedium);
    }
    return const EdgeInsets.all(AppDimensions.paddingLarge);
  }
}
