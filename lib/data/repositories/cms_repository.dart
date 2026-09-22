import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/cms_page.dart';
import 'base_repository.dart';

class CmsRepository extends BaseRepository {
  const CmsRepository(super.apiService);

  Future<CmsPage> fetchPage(String slug) async {
    final json = await apiService.getJson(ApiConstants.cmsPage(slug));
    return CmsPage.fromJson(ApiBody.dataMap(json));
  }
}
