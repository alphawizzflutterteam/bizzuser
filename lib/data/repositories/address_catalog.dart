import '../../core/constants/app_strings.dart';
import '../models/user_address.dart';

class AddressCatalog {
  AddressCatalog._();

  static const List<UserAddress> addresses = [
    UserAddress(
      id: 'demo-home',
      label: 'home',
      name: AppStrings.labelHome,
      address: AppStrings.sampleHomeAddress,
      lat: 22.7533,
      lng: 75.8937,
    ),
  ];
}
