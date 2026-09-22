class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.mainText = '',
    this.secondaryText = '',
    this.lat = 0,
    this.lng = 0,
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final double lat;
  final double lng;

  bool get hasCoordinates => lat != 0 && lng != 0;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'];
    final main = structured is Map
        ? structured['main_text']?.toString().trim() ?? ''
        : '';
    final secondary = structured is Map
        ? structured['secondary_text']?.toString().trim() ?? ''
        : '';
    return PlaceSuggestion(
      placeId: json['place_id']?.toString() ?? '',
      description: json['description']?.toString().trim() ?? '',
      mainText: main,
      secondaryText: secondary,
    );
  }

  factory PlaceSuggestion.fromApi(Map<String, dynamic> json) {
    final location = _asMap(json['location'] ?? json['geometry']);
    final nested = _asMap(location['location']);
    final coords = location['coordinates'] ?? json['coordinates'];
    var lat = _coord(
      json['lat'] ??
          json['latitude'] ??
          location['lat'] ??
          location['latitude'] ??
          nested['lat'] ??
          nested['latitude'],
    );
    var lng = _coord(
      json['lng'] ??
          json['longitude'] ??
          location['lng'] ??
          location['longitude'] ??
          nested['lng'] ??
          nested['longitude'],
    );
    if (coords is List && coords.length >= 2) {
      lng = _coord(coords[0]);
      lat = _coord(coords[1]);
    }
    final address =
        (json['address'] ?? json['description'] ?? json['name'] ?? json['title'])
            ?.toString()
            .trim() ??
        '';
    final city =
        (json['city'] ?? json['secondaryText'] ?? json['subtitle'])
            ?.toString()
            .trim() ??
        '';
    final id =
        (json['placeId'] ?? json['place_id'] ?? json['_id'] ?? json['id'] ?? address)
            .toString();
    return PlaceSuggestion(
      placeId: id,
      description: address,
      mainText: address.split(',').first.trim(),
      secondaryText: city,
      lat: lat,
      lng: lng,
    );
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  static double _coord(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PlaceDetails {
  const PlaceDetails({
    required this.address,
    required this.lat,
    required this.lng,
    this.city = '',
  });

  final String address;
  final double lat;
  final double lng;
  final String city;
}
