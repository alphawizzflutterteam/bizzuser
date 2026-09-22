import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class HomeMapBackground extends StatelessWidget {
  const HomeMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final headerGap = MediaQuery.paddingOf(context).top + 64;
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.mapLand),
        const Positioned.fill(child: CustomPaint(painter: HomeMapGridPainter())),
        Positioned(
          top: headerGap,
          left: 0,
          right: 0,
          child: Image.asset(
            AppAssets.homeMap,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}

class HomeMapGridPainter extends CustomPainter {
  const HomeMapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.mapLand);

    final roadFill = Paint()
      ..color = AppColors.mapRoad
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadEdge = Paint()
      ..color = AppColors.mapRoadLine
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final minor = Paint()
      ..color = AppColors.mapRoadLine.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 1; i < 12; i++) {
      final y = size.height * (i / 12);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
    for (var i = 1; i < 8; i++) {
      final x = size.width * (i / 8);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }

    final arteries = <Path>[
      Path()
        ..moveTo(0, size.height * 0.22)
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * 0.18,
          size.width,
          size.height * 0.28,
        ),
      Path()
        ..moveTo(0, size.height * 0.48)
        ..lineTo(size.width, size.height * 0.44),
      Path()
        ..moveTo(size.width * 0.32, 0)
        ..lineTo(size.width * 0.38, size.height),
      Path()
        ..moveTo(size.width * 0.7, 0)
        ..quadraticBezierTo(
          size.width * 0.66,
          size.height * 0.5,
          size.width * 0.78,
          size.height,
        ),
    ];

    for (final path in arteries) {
      canvas.drawPath(path, roadEdge);
      canvas.drawPath(path, roadFill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
