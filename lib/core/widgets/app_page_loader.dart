import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppPageLoader extends StatelessWidget {
  const AppPageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.brandYellow,
      ),
    );
  }
}

class AppPageLoadingGate extends StatelessWidget {
  const AppPageLoadingGate({
    super.key,
    required this.loading,
    required this.child,
  });

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (loading) return const AppPageLoader();
    return child;
  }
}
