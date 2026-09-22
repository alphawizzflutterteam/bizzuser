import '../../core/constants/app_strings.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/app_utils.dart';

Future<T?> runApi<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on ApiException catch (error) {
    AppUtils.showError(error.message);
    return null;
  } catch (_) {
    AppUtils.showError(AppStrings.somethingWentWrong);
    return null;
  }
}
