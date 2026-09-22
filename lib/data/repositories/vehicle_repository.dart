import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/vehicle_type.dart';
import 'base_repository.dart';

class VehicleRepository extends BaseRepository {
  const VehicleRepository(super.apiService);

  Future<List<VehicleType>> fetchTypes() async {
    final json = await apiService.getJson(ApiConstants.vehicleTypes);
    return ApiBody.dataList(json)
        .map(VehicleType.fromJson)
        .where((item) => item.active && item.id.isNotEmpty)
        .toList(growable: false);
  }
}
