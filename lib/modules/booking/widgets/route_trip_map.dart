import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/ride_map_backdrop.dart';
import '../../../data/models/ride_location.dart';

bool canShowGoogleMap() {
  if (kIsWeb) return false;
  if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class RouteTripMap extends StatefulWidget {
  const RouteTripMap({
    super.key,
    required this.pickup,
    required this.drop,
    this.distance = '',
    this.driverLat,
    this.driverLng,
  });

  final RideLocation pickup;
  final RideLocation drop;
  final String distance;
  final double? driverLat;
  final double? driverLng;

  @override
  State<RouteTripMap> createState() => _RouteTripMapState();
}

class _RouteTripMapState extends State<RouteTripMap> {
  GoogleMapController? _controller;

  LatLng get _pickup => LatLng(
        widget.pickup.lat != 0 ? widget.pickup.lat : 22.7533,
        widget.pickup.lng != 0 ? widget.pickup.lng : 75.8937,
      );

  LatLng get _drop => LatLng(
        widget.drop.lat != 0 ? widget.drop.lat : 22.7196,
        widget.drop.lng != 0 ? widget.drop.lng : 75.8577,
      );

  String get _distanceLabel {
    final value = widget.distance.trim();
    if (value.isNotEmpty) return value;
    return formatKmDistance(_haversineKm(_pickup, _drop));
  }

  @override
  void didUpdateWidget(covariant RouteTripMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickup.lat != widget.pickup.lat ||
        oldWidget.pickup.lng != widget.pickup.lng ||
        oldWidget.drop.lat != widget.drop.lat ||
        oldWidget.drop.lng != widget.drop.lng ||
        oldWidget.driverLat != widget.driverLat ||
        oldWidget.driverLng != widget.driverLng) {
      _fitBounds();
    }
  }

  LatLng? get _driver {
    final lat = widget.driverLat;
    final lng = widget.driverLng;
    if (lat == null || lng == null) return null;
    if (lat == 0 && lng == 0) return null;
    return LatLng(lat, lng);
  }

  Future<void> _fitBounds() async {
    final controller = _controller;
    if (controller == null) return;
    final driver = _driver;
    final lats = <double>[_pickup.latitude, _drop.latitude];
    final lngs = <double>[_pickup.longitude, _drop.longitude];
    if (driver != null) {
      lats.add(driver.latitude);
      lngs.add(driver.longitude);
    }
    final bounds = LatLngBounds(
      southwest: LatLng(lats.reduce(math.min), lngs.reduce(math.min)),
      northeast: LatLng(lats.reduce(math.max), lngs.reduce(math.max)),
    );
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!canShowGoogleMap()) {
      return _FallbackRouteMap(distance: _distanceLabel);
    }

    final routePoints = _dottedRoutePoints(_pickup, _drop);
    final driver = _driver;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        ),
      ),
      Marker(
        markerId: const MarkerId('drop'),
        position: _drop,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
      if (driver != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: driver,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _pickup, zoom: 13.2),
          onMapCreated: (controller) async {
            _controller = controller;
            await Future<void>.delayed(const Duration(milliseconds: 250));
            await _fitBounds();
          },
          markers: markers,
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: AppColors.brandBlack,
              width: 4,
              patterns: [
                PatternItem.dot,
                PatternItem.gap(12),
              ],
            ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          liteModeEnabled: false,
        ),
        Align(
          alignment: const Alignment(0, -0.18),
          child: _DistanceBadge(text: _distanceLabel),
        ),
      ],
    );
  }
}

class _FallbackRouteMap extends StatelessWidget {
  const _FallbackRouteMap({required this.distance});

  final String distance;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RideMapBackdrop(showRoute: true),
        CustomPaint(painter: _DottedRoutePainter()),
        Align(
          alignment: const Alignment(0, -0.18),
          child: _DistanceBadge(text: distance),
        ),
      ],
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppText(
        text: text.isEmpty ? AppStrings.distanceSample : text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.brandBlack,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _DottedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandBlack
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final start = Offset(size.width * 0.28, size.height * 0.28);
    final end = Offset(size.width * 0.72, size.height * 0.42);
    final mid = Offset(size.width * 0.55, size.height * 0.22);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 2.2, paint);
        }
        distance += 10;
      }
    }
    canvas.drawCircle(start, 7, Paint()..color = AppColors.brandYellow);
    canvas.drawCircle(start, 3.2, Paint()..color = AppColors.brandBlack);
    canvas.drawCircle(end, 7, Paint()..color = AppColors.dropPin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

List<LatLng> _dottedRoutePoints(LatLng start, LatLng end) {
  const steps = 24;
  return [
    for (var i = 0; i <= steps; i++)
      LatLng(
        start.latitude + (end.latitude - start.latitude) * (i / steps),
        start.longitude + (end.longitude - start.longitude) * (i / steps),
      ),
  ];
}

double _haversineKm(LatLng a, LatLng b) {
  const earth = 6371.0;
  final dLat = _rad(b.latitude - a.latitude);
  final dLng = _rad(b.longitude - a.longitude);
  final lat1 = _rad(a.latitude);
  final lat2 = _rad(b.latitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return 2 * earth * math.asin(math.sqrt(h));
}

double _rad(double deg) => deg * math.pi / 180;

String formatKmDistance(double km) {
  if (km <= 0) return AppStrings.distanceSample;
  if (km < 10) {
    final rounded = (km * 10).round() / 10;
    final label = rounded % 1 == 0
        ? rounded.toStringAsFixed(0).padLeft(2, '0')
        : rounded.toStringAsFixed(1);
    return '$label km';
  }
  return '${km.round()} km';
}
