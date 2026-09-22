import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/user_address.dart';
import 'base_repository.dart';

class AddressRepository extends BaseRepository {
  const AddressRepository(super.apiService);

  Future<List<UserAddress>> fetchAddresses() async {
    final json = await apiService.getJson(ApiConstants.addresses);
    return ApiBody.dataList(json)
        .map(UserAddress.fromJson)
        .where((item) => item.address.isNotEmpty || item.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<UserAddress> createAddress({
    required String label,
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final json = await apiService.postJson(ApiConstants.addresses, {
      'label': label.trim(),
      'name': name.trim(),
      'address': address.trim(),
      'lat': lat,
      'lng': lng,
    });
    final map = ApiBody.dataMap(json);
    return UserAddress.fromJson(map.isEmpty ? json : map);
  }

  Future<UserAddress> updateAddress({
    required String id,
    required String label,
    required String name,
    String? address,
    double? lat,
    double? lng,
  }) async {
    final body = <String, dynamic>{
      'label': label.trim(),
      'name': name.trim(),
    };
    final line = address?.trim() ?? '';
    if (line.isNotEmpty) body['address'] = line;
    if (lat != null) body['lat'] = lat;
    if (lng != null) body['lng'] = lng;
    final json = await apiService.putJson(ApiConstants.address(id), body);
    final map = ApiBody.dataMap(json);
    return UserAddress.fromJson(map.isEmpty ? json : map);
  }

  Future<String> deleteAddress(String id) async {
    final json = await apiService.deleteJson(ApiConstants.address(id));
    return ApiBody.message(json, fallback: '');
  }
}
