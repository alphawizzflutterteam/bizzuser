import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CreamWashBackground extends StatelessWidget {
  const CreamWashBackground({super.key, required this.child});

  final Widget child;

  static const BoxDecoration decoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.profileWash,
        AppColors.cream,
        AppColors.white,
      ],
      stops: [0, 0.22, 0.48],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: decoration, child: child);
  }
}

class CreamWashScaffold extends StatelessWidget {
  const CreamWashScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileWash,
      floatingActionButton: floatingActionButton,
      body: CreamWashBackground(child: body),
    );
  }
}
