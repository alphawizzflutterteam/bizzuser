import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/place_suggestion.dart';
import 'base_repository.dart';

class PlacesRepository extends BaseRepository {
  const PlacesRepository(super.apiService);

  Future<List<PlaceSuggestion>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final json = await apiService.getJson(
      ApiConstants.placesSearch,
      query: {'q': q},
    );
    return _suggestions(json);
  }

  Future<PlaceDetails?> geocode(String address) async {
    final value = address.trim();
    if (value.isEmpty) return null;
    final json = await apiService.getJson(
      ApiConstants.placesGeocode,
      query: {'address': value},
    );
    return _details(json, fallbackAddress: value);
  }

  Future<PlaceDetails?> reverse({
    required double lat,
    required double lng,
  }) async {
    final json = await apiService.getJson(
      ApiConstants.placesReverse,
      query: {'lat': '$lat', 'lng': '$lng'},
    );
    return _details(json);
  }

  Future<List<Map<String, dynamic>>> fetchCities() async {
    final json = await apiService.getJson(ApiConstants.publicCities);
    return ApiBody.dataList(json);
  }

  List<PlaceSuggestion> _suggestions(Map<String, dynamic> json) {
    var rows = ApiBody.dataList(json);
    if (rows.isEmpty) {
      final map = ApiBody.dataMap(json);
      rows = ApiBody.asMapList(
        map['places'] ??
            map['results'] ??
            map['predictions'] ??
            map['suggestions'],
      );
      if (rows.isEmpty &&
          (map['address'] != null || map['description'] != null)) {
        rows = [map];
      }
    }
    return rows
        .map(PlaceSuggestion.fromApi)
        .where((item) => item.description.isNotEmpty)
        .toList(growable: false);
  }

  PlaceDetails? _details(
    Map<String, dynamic> json, {
    String fallbackAddress = '',
  }) {
    final map = ApiBody.dataMap(json);
    final data = map.isEmpty ? json : map;
    final nested = ApiBody.asMap(data['location']) ?? {};
    final coords = nested['coordinates'] ?? data['coordinates'];
    var lat = ApiBody.asNum(
      data['lat'] ?? data['latitude'] ?? nested['lat'],
    ).toDouble();
    var lng = ApiBody.asNum(
      data['lng'] ?? data['longitude'] ?? nested['lng'],
    ).toDouble();
    if (coords is List && coords.length >= 2) {
      lng = ApiBody.asNum(coords[0]).toDouble();
      lat = ApiBody.asNum(coords[1]).toDouble();
    }
    final address =
        (data['address'] ?? data['formattedAddress'] ?? fallbackAddress)
            .toString()
            .trim();
    if (address.isEmpty || (lat == 0 && lng == 0)) return null;
    return PlaceDetails(
      address: address,
      lat: lat,
      lng: lng,
      city: (data['city'] ?? '').toString().trim(),
    );
  }
}
