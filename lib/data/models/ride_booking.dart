import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/media_url.dart';
import 'ride_driver.dart';
import 'ride_location.dart';
import 'ride_payment.dart';

enum RideBookingStatus { ongoing, completed, cancelled }

class RideBooking {
  const RideBooking({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.pickup,
    required this.drop,
    required this.distance,
    required this.driver,
    required this.vehicleLabel,
    this.displayId = '',
    this.otp = '',
    this.paymentLabel = '',
    this.cancelReason = '',
    this.baseFare = 0,
    this.gst = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.distanceFare = 0,
    this.waitingCharge = 0,
    this.discount = 0,
    this.total = 0,
    this.rawStatus = '',
    this.etaMinutes = 0,
    this.sharePath = '',
    this.shareToken = '',
    this.couponCode = '',
    this.vehicleType = '',
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.paymentOptions = const [],
  });

  final String id;
  final RideBookingStatus status;
  final String statusLabel;
  final RideLocation pickup;
  final RideLocation drop;
  final String distance;
  final RideDriver driver;
  final String vehicleLabel;
  final String displayId;
  final String otp;
  final String paymentLabel;
  final String cancelReason;
  final double baseFare;
  final double gst;
  final double cgst;
  final double sgst;
  final double igst;
  final double distanceFare;
  final double waitingCharge;
  final double discount;
  final double total;
  final String rawStatus;
  final int etaMinutes;
  final String sharePath;
  final String shareToken;
  final String couponCode;
  final String vehicleType;
  final String paymentMethod;
  final String paymentStatus;
  final List<RidePaymentOption> paymentOptions;

  String get bookingCode => displayId.isNotEmpty ? displayId : id;

  String get normalizedStatus => rawStatus.trim().toLowerCase();

  bool get isSearching => normalizedStatus == 'searching';

  bool get isAssigned {
    final value = normalizedStatus;
    return value == 'accepted' || value == 'arrived' || value == 'ongoing';
  }

  bool get isLive {
    final value = normalizedStatus;
    return value == 'searching' ||
        value == 'accepted' ||
        value == 'arrived' ||
        value == 'ongoing';
  }

  bool get isCancelled =>
      normalizedStatus == 'cancelled' || status == RideBookingStatus.cancelled;

  bool get isCompleted =>
      normalizedStatus == 'completed' || status == RideBookingStatus.completed;

  bool get isPaid => paymentStatus.trim().toLowerCase() == 'paid';

  bool get isPaymentPending {
    final value = paymentStatus.trim().toLowerCase();
    if (value == 'paid') return false;
    if (value == 'pending' || value.isEmpty) return isCompleted;
    return false;
  }

  bool get canCancel {
    final value = normalizedStatus;
    if (value.isEmpty) return status == RideBookingStatus.ongoing;
    return value == 'searching' || value == 'accepted' || value == 'arrived';
  }

  bool get showOtp {
    if (otp.isEmpty) return false;
    final value = normalizedStatus;
    return value == 'accepted' || value == 'arrived';
  }

  String get liveStatusUiLabel {
    switch (normalizedStatus) {
      case 'searching':
        return AppStrings.searchingForDriver;
      case 'accepted':
        return AppStrings.driverOnTheWayLabel;
      case 'arrived':
        return AppStrings.driverHasArrived;
      case 'ongoing':
        return AppStrings.tripInProgress;
      case 'completed':
        return AppStrings.rideStatusCompleted;
      case 'cancelled':
        return AppStrings.rideStatusCancelled;
      default:
        if (statusLabel.trim().isNotEmpty) return statusLabel;
        if (isCompleted) return AppStrings.rideStatusCompleted;
        if (isCancelled) return AppStrings.rideStatusCancelled;
        return AppStrings.searchingForDriver;
    }
  }

  String get etaBanner {
    switch (normalizedStatus) {
      case 'searching':
        return AppStrings.searchingForDriver;
      case 'accepted':
        if (etaMinutes > 0) return AppStrings.driverOnTheWayEta(etaMinutes);
        return AppStrings.driverOnTheWayLabel;
      case 'arrived':
        return AppStrings.driverHasArrived;
      case 'ongoing':
        return AppStrings.tripInProgress;
      case 'completed':
        return AppStrings.rideStatusCompleted;
      case 'cancelled':
        if (cancelReason.isNotEmpty) return cancelReason;
        return AppStrings.rideStatusCancelled;
      default:
        if (statusLabel.trim().isNotEmpty) return statusLabel;
        return AppStrings.onTheWay;
    }
  }

  String get shareUrl {
    if (sharePath.trim().isNotEmpty) {
      return MediaUrl.resolve(sharePath);
    }
    if (shareToken.trim().isEmpty) return '';
    return MediaUrl.resolve('/public/rides/share/$shareToken');
  }

  String get driverDisplayName {
    if (driver.hasName) return driver.name;
    if (status == RideBookingStatus.cancelled) {
      if (cancelReason.isNotEmpty) return cancelReason;
      return statusLabel;
    }
    return AppStrings.searchingForRides;
  }

  RideBooking copyWith({
    RideBookingStatus? status,
    String? statusLabel,
    String? otp,
    String? paymentMethod,
    String? paymentLabel,
    String? paymentStatus,
    String? cancelReason,
    String? rawStatus,
    double? total,
    List<RidePaymentOption>? paymentOptions,
  }) {
    return RideBooking(
      id: id,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      pickup: pickup,
      drop: drop,
      distance: distance,
      driver: driver,
      vehicleLabel: vehicleLabel,
      displayId: displayId,
      otp: otp ?? this.otp,
      paymentLabel: paymentLabel ?? this.paymentLabel,
      cancelReason: cancelReason ?? this.cancelReason,
      baseFare: baseFare,
      gst: gst,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      distanceFare: distanceFare,
      waitingCharge: waitingCharge,
      discount: discount,
      total: total ?? this.total,
      rawStatus: rawStatus ?? this.rawStatus,
      etaMinutes: etaMinutes,
      sharePath: sharePath,
      shareToken: shareToken,
      couponCode: couponCode,
      vehicleType: vehicleType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentOptions: paymentOptions ?? this.paymentOptions,
    );
  }

  factory RideBooking.fromJson(Map<String, dynamic> json) {
    final data = _rideMap(json);
    final breakdown =
        ApiBody.asMap(data['fareBreakdown'] ?? data['breakdown']) ?? {};
    final statusValue = (data['status'] ?? '').toString();
    final status = _status(statusValue);
    final id = (data['_id'] ?? data['id'])?.toString() ?? '';
    final code =
        (data['bookingId'] ?? data['bookingCode'] ?? data['rideCode'])
            ?.toString()
            .trim() ??
        '';
    final vehicleType =
        _vehicleType(data['vehicleType'] ?? data['vehicleLabel']) ;
    final driver = RideDriver.fromJson(
      data['driver'] ?? data['assignedDriver'] ?? data['offeredDriver'],
      vehicle: data['vehicle'],
    );
    final distanceLabel =
        (data['distanceLabel'] ?? data['distanceText'])?.toString().trim() ??
        '';
    final root = ApiBody.dataMap(json);
    final options = RidePaymentOption.listFrom(
      data['paymentOptions'] ?? root['paymentOptions'],
    );
    return RideBooking(
      id: id,
      displayId: code.isNotEmpty ? code : id,
      status: status,
      statusLabel: _statusLabel(
        data['statusLabel']?.toString(),
        statusValue,
        status,
      ),
      pickup: RideLocation.fromJson(data['pickup']),
      drop: RideLocation.fromJson(data['drop']),
      distance: distanceLabel.isNotEmpty
          ? distanceLabel
          : _distance(data['distanceKm'] ?? data['distance']),
      driver: driver,
      vehicleLabel: _vehicleLabel(
        data['label'] ?? data['vehicleType'] ?? data['vehicle'] ?? data['vehicleLabel'],
      ),
      otp: data['otp']?.toString().trim() ?? '',
      paymentLabel: (data['paymentLabel'] ?? data['paymentMethod'])
              ?.toString()
              .trim() ??
          '',
      cancelReason: (data['cancelReason'] ?? '').toString().trim(),
      baseFare: ApiBody.asNum(
        breakdown['baseFare'] ?? data['baseFare'],
      ).toDouble(),
      gst: ApiBody.asNum(breakdown['tax'] ?? data['tax']).toDouble(),
      cgst: ApiBody.asNum(breakdown['cgst'] ?? data['cgst']).toDouble(),
      sgst: ApiBody.asNum(breakdown['sgst'] ?? data['sgst']).toDouble(),
      igst: ApiBody.asNum(breakdown['igst'] ?? data['igst']).toDouble(),
      distanceFare: ApiBody.asNum(
        breakdown['distanceFare'] ?? data['distanceFare'],
      ).toDouble(),
      waitingCharge: ApiBody.asNum(
        breakdown['waitingCharge'] ?? data['waitingCharge'],
      ).toDouble(),
      discount: ApiBody.asNum(
        breakdown['discount'] ?? data['couponDiscount'] ?? data['discount'],
      ).toDouble(),
      total: ApiBody.asNum(
        breakdown['total'] ?? data['fare'] ?? data['total'],
      ).toDouble(),
      rawStatus: statusValue.trim(),
      etaMinutes: ApiBody.asInt(data['etaMinutes'] ?? data['eta']) ?? 0,
      sharePath: (data['sharePath'] ?? '').toString().trim(),
      shareToken: (data['shareToken'] ?? '').toString().trim(),
      couponCode: (data['couponCode'] ?? '').toString().trim(),
      vehicleType: vehicleType,
      paymentMethod: RidePaymentOption.normalize(
        (data['paymentMethod'] ?? '').toString(),
      ),
      paymentStatus: (data['paymentStatus'] ?? '').toString().trim().toLowerCase(),
      paymentOptions: options,
    );
  }

  static Map<String, dynamic> _rideMap(Map<String, dynamic> json) {
    final map = ApiBody.dataMap(json);
    final data = map.isEmpty ? json : map;
    final nested = ApiBody.asMap(data['ride']);
    if (nested != null && nested.isNotEmpty) {
      return nested;
    }
    return data;
  }

  static RideBookingStatus _status(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.contains('cancel')) return RideBookingStatus.cancelled;
    if (value.contains('complete')) return RideBookingStatus.completed;
    return RideBookingStatus.ongoing;
  }

  static String _statusLabel(
    String? label,
    String raw,
    RideBookingStatus status,
  ) {
    final trimmed = label?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    switch (raw.trim().toLowerCase()) {
      case 'searching':
        return AppStrings.searchingForDriver;
      case 'accepted':
        return AppStrings.driverOnTheWayLabel;
      case 'arrived':
        return AppStrings.driverHasArrived;
      case 'ongoing':
        return AppStrings.tripInProgress;
      case 'completed':
        return AppStrings.rideStatusCompleted;
      case 'cancelled':
        return AppStrings.rideStatusCancelled;
    }
    switch (status) {
      case RideBookingStatus.completed:
        return AppStrings.rideStatusCompleted;
      case RideBookingStatus.cancelled:
        return AppStrings.rideStatusCancelled;
      case RideBookingStatus.ongoing:
        return AppStrings.driverOnTheWayLabel;
    }
  }

  static String _distance(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed.toLowerCase().contains('km')) return trimmed;
      final parsed = num.tryParse(trimmed);
      if (parsed == null) return trimmed;
      return _km(parsed);
    }
    if (value is num) return _km(value);
    return '';
  }

  static String _km(num km) {
    if (km <= 0) return '';
    if (km % 1 == 0) {
      return '${km.toInt().toString().padLeft(2, '0')} km';
    }
    return '${km.toStringAsFixed(2)} km';
  }

  static String _vehicleType(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    final map = ApiBody.asMap(raw);
    if (map == null) return '';
    return (map['vehicleType'] ?? map['name'] ?? map['category'] ?? '')
        .toString()
        .trim();
  }

  static String _vehicleLabel(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    final map = ApiBody.asMap(raw);
    if (map == null) return '';
    return (map['label'] ?? map['name'] ?? map['shortName'] ?? '')
        .toString()
        .trim();
  }
}
