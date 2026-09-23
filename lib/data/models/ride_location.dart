class RideLocation {
  const RideLocation({
    required this.title,
    required this.subtitle,
    this.lat = 0,
    this.lng = 0,
  });

  final String title;
  final String subtitle;
  final double lat;
  final double lng;

  bool get hasCoordinates => lat != 0 && lng != 0;

  bool get isBlank => title.trim().isEmpty && subtitle.trim().isEmpty;

  String get cityLabel {
    final city = subtitle.split(',').first.trim();
    return city;
  }

  String get routeLine {
    final trimmedTitle = title.trim();
    final trimmedSubtitle = subtitle.trim();
    if (trimmedTitle.toLowerCase() == 'current location' &&
        trimmedSubtitle.isNotEmpty) {
      return trimmedSubtitle;
    }
    if (trimmedTitle.isEmpty) return cityLabel;
    if (cityLabel.isEmpty) return trimmedTitle;
    if (title.toLowerCase().contains(cityLabel.toLowerCase())) return title;
    return '$title, $cityLabel';
  }

  /// Request payload. There is no implicit default city: callers must make
  /// sure [hasCoordinates] is true (the backend rejects missing lat/lng).
  Map<String, dynamic> toApiJson({
    double? fallbackLat,
    double? fallbackLng,
  }) {
    return {
      'address': routeLine,
      'lat': lat != 0 ? lat : fallbackLat,
      'lng': lng != 0 ? lng : fallbackLng,
    };
  }

  factory RideLocation.fromJson(dynamic raw) {
    if (raw is String) {
      return RideLocation.fromAddress(raw);
    }
    if (raw is! Map) {
      return const RideLocation(title: '', subtitle: '');
    }
    final json = raw.map((key, value) => MapEntry(key.toString(), value));
    final address =
        (json['address'] ?? json['title'] ?? json['name'])?.toString().trim() ??
        '';
    final parsed = RideLocation.fromAddress(address);
    return RideLocation(
      title: parsed.title,
      subtitle: parsed.subtitle,
      lat: _coord(json['lat'] ?? json['latitude']),
      lng: _coord(json['lng'] ?? json['longitude']),
    );
  }

  factory RideLocation.fromAddress(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      return const RideLocation(title: '', subtitle: '');
    }
    final parts = trimmed.split(',');
    final title = parts.first.trim();
    final subtitle = parts.length > 1
        ? parts.sublist(1).join(',').trim()
        : '';
    return RideLocation(title: title, subtitle: subtitle);
  }

  static double _coord(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
