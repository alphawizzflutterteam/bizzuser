import 'package:get/get.dart';

import '../../core/constants/map_constants.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/api_logger.dart';
import '../models/place_suggestion.dart';

class PlacesService extends GetConnect {
  PlacesService();

  @override
  void onInit() {
    httpClient.baseUrl = MapConstants.placesBaseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    super.onInit();
  }

  Future<List<PlaceSuggestion>> autocomplete(String input) async {
    final query = input.trim();
    if (query.length < 2) return const [];

    final path =
        '${MapConstants.placesBaseUrl}${MapConstants.autocompletePath}';
    final response = await get(
      MapConstants.autocompletePath,
      query: {
        'input': query,
        'key': MapConstants.googleMapsApiKey,
        'components': 'country:in',
      },
    );
    final json = ApiBody.asMap(response.body) ?? {};
    ApiLogger.success(
      'GET',
      path,
      statusCode: response.statusCode,
      response: {
        'status': json['status'],
        'count': (json['predictions'] as List?)?.length,
      },
    );
    final status = json['status']?.toString() ?? '';
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      return const [];
    }
    return ApiBody.asMapList(json['predictions'])
        .map(PlaceSuggestion.fromJson)
        .where((item) => item.placeId.isNotEmpty && item.description.isNotEmpty)
        .toList(growable: false);
  }

  Future<PlaceDetails?> details(String placeId) async {
    final id = placeId.trim();
    if (id.isEmpty) return null;

    final path = '${MapConstants.placesBaseUrl}${MapConstants.detailsPath}';
    final response = await get(
      MapConstants.detailsPath,
      query: {
        'place_id': id,
        'fields': 'formatted_address,geometry',
        'key': MapConstants.googleMapsApiKey,
      },
    );
    final json = ApiBody.asMap(response.body) ?? {};
    ApiLogger.success(
      'GET',
      path,
      statusCode: response.statusCode,
      response: {'status': json['status']},
    );
    if (json['status']?.toString() != 'OK') return null;
    final result = ApiBody.asMap(json['result']) ?? {};
    final geometry = ApiBody.asMap(result['geometry']) ?? {};
    final location = ApiBody.asMap(geometry['location']) ?? {};
    final lat = ApiBody.asNum(location['lat']).toDouble();
    final lng = ApiBody.asNum(location['lng']).toDouble();
    final address = result['formatted_address']?.toString().trim() ?? '';
    if (address.isEmpty || (lat == 0 && lng == 0)) return null;
    return PlaceDetails(address: address, lat: lat, lng: lng);
  }

  Future<PlaceDetails?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final path = '${MapConstants.placesBaseUrl}${MapConstants.geocodePath}';
    final response = await get(
      MapConstants.geocodePath,
      query: {'latlng': '$lat,$lng', 'key': MapConstants.googleMapsApiKey},
    );
    final json = ApiBody.asMap(response.body) ?? {};
    ApiLogger.success(
      'GET',
      path,
      statusCode: response.statusCode,
      response: {'status': json['status']},
    );
    if (json['status']?.toString() != 'OK') return null;
    final results = ApiBody.asMapList(json['results']);
    if (results.isEmpty) return null;
    final address = results.first['formatted_address']?.toString().trim() ?? '';
    if (address.isEmpty) return null;
    return PlaceDetails(address: address, lat: lat, lng: lng);
  }

  Future<PlaceDetails?> geocode(String address) async {
    final value = address.trim();
    if (value.isEmpty) return null;
    final path = '${MapConstants.placesBaseUrl}${MapConstants.geocodePath}';
    final response = await get(
      MapConstants.geocodePath,
      query: {
        'address': value,
        'key': MapConstants.googleMapsApiKey,
        'region': 'in',
      },
    );
    final json = ApiBody.asMap(response.body) ?? {};
    ApiLogger.success(
      'GET',
      path,
      statusCode: response.statusCode,
      response: {'status': json['status']},
    );
    if (json['status']?.toString() != 'OK') return null;
    final results = ApiBody.asMapList(json['results']);
    if (results.isEmpty) return null;
    final first = results.first;
    final formatted = first['formatted_address']?.toString().trim() ?? value;
    final geometry = ApiBody.asMap(first['geometry']) ?? {};
    final location = ApiBody.asMap(geometry['location']) ?? {};
    final lat = ApiBody.asNum(location['lat']).toDouble();
    final lng = ApiBody.asNum(location['lng']).toDouble();
    if (formatted.isEmpty || (lat == 0 && lng == 0)) return null;
    return PlaceDetails(address: formatted, lat: lat, lng: lng);
  }
}
