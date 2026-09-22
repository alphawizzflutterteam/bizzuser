import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_dimensions.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = AppDimensions.loginLogoWidth});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.logo, width: width, fit: BoxFit.contain);
  }
}
