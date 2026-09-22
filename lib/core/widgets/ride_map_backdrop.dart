import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class RideMapBackdrop extends StatelessWidget {
  const RideMapBackdrop({
    super.key,
    this.showRoute = false,
    this.showHalo = true,
  });

  final bool showRoute;
  final bool showHalo;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(showRoute: showRoute, showHalo: showHalo),
      child: const SizedBox.expand(),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.showRoute, required this.showHalo});

  final bool showRoute;
  final bool showHalo;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.mapLand);

    final parkPaint = Paint()..color = AppColors.mapPark;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.22, size.height * 0.18),
        width: size.width * 0.28,
        height: size.height * 0.12,
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.58,
          size.height * 0.08,
          size.width * 0.34,
          size.height * 0.16,
        ),
        const Radius.circular(18),
      ),
      parkPaint,
    );

    final roadPaint = Paint()
      ..color = AppColors.mapRoad
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadBorder = Paint()
      ..color = AppColors.mapRoadLine
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final h1 = Path()
      ..moveTo(0, size.height * 0.32)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.28,
        size.width,
        size.height * 0.36,
      );
    final h2 = Path()
      ..moveTo(0, size.height * 0.52)
      ..lineTo(size.width, size.height * 0.48);
    final v1 = Path()
      ..moveTo(size.width * 0.28, 0)
      ..lineTo(size.width * 0.34, size.height);
    final v2 = Path()
      ..moveTo(size.width * 0.72, 0)
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.5,
        size.width * 0.78,
        size.height,
      );

    for (final path in [h1, h2, v1, v2]) {
      canvas.drawPath(path, roadBorder);
      canvas.drawPath(path, roadPaint);
    }

    final pickup = Offset(size.width * 0.5, size.height * 0.34);
    if (showHalo) {
      canvas.drawCircle(pickup, 54, Paint()..color = AppColors.mapHalo);
      canvas.drawCircle(
        pickup,
        18,
        Paint()..color = AppColors.brandYellow.withValues(alpha: 0.9),
      );
    }

    _drawPin(canvas, pickup, AppColors.brandYellow);

    if (showRoute) {
      final drop = Offset(size.width * 0.62, size.height * 0.58);
      final route = Path()
        ..moveTo(pickup.dx, pickup.dy)
        ..quadraticBezierTo(
          size.width * 0.78,
          size.height * 0.42,
          drop.dx,
          drop.dy,
        );
      canvas.drawPath(
        route,
        Paint()
          ..color = AppColors.brandBlack
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      _drawPin(canvas, drop, AppColors.brandBlack);
    }
  }

  void _drawPin(Canvas canvas, Offset offset, Color color) {
    final pin = Path()
      ..moveTo(offset.dx, offset.dy + 16)
      ..quadraticBezierTo(
        offset.dx - 16,
        offset.dy - 4,
        offset.dx,
        offset.dy - 18,
      )
      ..quadraticBezierTo(
        offset.dx + 16,
        offset.dy - 4,
        offset.dx,
        offset.dy + 16,
      );
    canvas.drawPath(pin, Paint()..color = color);
    canvas.drawCircle(
      Offset(offset.dx, offset.dy - 6),
      5,
      Paint()..color = AppColors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.showRoute != showRoute ||
        oldDelegate.showHalo != showHalo;
  }
}

class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: AppDimensions.iconSizeSmall + 2,
            color: iconColor ?? AppColors.brandBlack,
          ),
        ),
      ),
    );
  }
}
