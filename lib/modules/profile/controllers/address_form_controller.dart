import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/run_api.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/location_pick_args.dart';
import '../../../data/models/place_suggestion.dart';
import '../../../data/models/ride_location.dart';
import '../../../data/models/user_address.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../data/services/places_service.dart';
import '../../home/controllers/home_controller.dart';
import 'saved_addresses_controller.dart';

class AddressFormController extends GetxController {
  static const defaultLat = 22.7533;
  static const defaultLng = 75.8937;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final labelController = TextEditingController();
  final searchController = TextEditingController();
  final isLoading = false.obs;
  final isSearchingPlaces = false.obs;
  final isResolvingAddress = false.obs;
  final suggestions = <PlaceSuggestion>[].obs;
  final mapLat = defaultLat.obs;
  final mapLng = defaultLng.obs;
  String _label = 'home';
  UserAddress? editing;
  LocationPickTarget? pickTarget;
  GoogleMapController? mapController;
  Timer? _debounce;
  Timer? _mapDebounce;
  bool _applyingSuggestion = false;
  bool _programmaticMove = false;

  static const labels = [
    (AppStrings.labelHome, 'home'),
    (AppStrings.labelWork, 'work'),
    (AppStrings.labelOther, 'other'),
  ];

  bool get isEditing => editing != null && editing!.id.isNotEmpty;

  bool get isLocationPick => pickTarget != null;

  bool get isPickupPick => pickTarget == LocationPickTarget.pickup;

  String get title {
    if (pickTarget == LocationPickTarget.pickup) {
      return AppStrings.pickupLocation;
    }
    if (pickTarget == LocationPickTarget.drop) {
      return AppStrings.dropLocation;
    }
    return isEditing ? AppStrings.editAddress : AppStrings.addAddress;
  }

  String get saveButtonTitle =>
      isLocationPick ? AppStrings.confirmLocation : AppStrings.saveAddress;

  bool get canShowMap {
    if (kIsWeb) return false;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  CameraPosition get initialCamera => CameraPosition(
        target: LatLng(mapLat.value, mapLng.value),
        zoom: 15.5,
      );

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is LocationPickArgs) {
      pickTarget = args.target;
      _seedFromHome(args.target);
      _label = 'home';
      nameController.text = AppStrings.labelHome;
      if (addressController.text.trim().isEmpty) {
        _resolveFromMap(mapLat.value, mapLng.value);
      }
      if (pickTarget == LocationPickTarget.drop) {
        _loadRecentDestinations();
      }
    } else if (args is UserAddress) {
      editing = args;
      _label = args.label.isEmpty ? 'home' : args.label;
      nameController.text = args.name;
      addressController.text = args.address;
      mapLat.value = args.lat == 0 ? defaultLat : args.lat;
      mapLng.value = args.lng == 0 ? defaultLng : args.lng;
    } else {
      _label = 'home';
      nameController.text = AppStrings.labelHome;
      _resolveFromMap(mapLat.value, mapLng.value);
    }
    labelController.text = _labelTitle(_label);
  }

  void _seedFromHome(LocationPickTarget target) {
    if (!Get.isRegistered<HomeController>()) return;
    final home = Get.find<HomeController>();
    final current =
        target == LocationPickTarget.pickup ? home.pickup.value : home.drop.value;
    if (current.isBlank && !current.hasCoordinates) return;
    if (current.routeLine.trim().isNotEmpty) {
      addressController.text = current.routeLine;
    }
    mapLat.value = current.lat == 0 ? defaultLat : current.lat;
    mapLng.value = current.lng == 0 ? defaultLng : current.lng;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onCameraMove(CameraPosition position) {
    mapLat.value = position.target.latitude;
    mapLng.value = position.target.longitude;
  }

  void onCameraIdle() {
    if (_programmaticMove) {
      _programmaticMove = false;
      return;
    }
    _mapDebounce?.cancel();
    _mapDebounce = Timer(const Duration(milliseconds: 450), () {
      _resolveFromMap(mapLat.value, mapLng.value);
    });
  }

  Future<void> _resolveFromMap(double lat, double lng) async {
    isResolvingAddress.value = true;
    try {
      PlaceDetails? details;
      if (Get.isRegistered<PlacesService>()) {
        details = await Get.find<PlacesService>().reverseGeocode(
          lat: lat,
          lng: lng,
        );
      }
      details ??= Get.isRegistered<PlacesRepository>()
          ? await Get.find<PlacesRepository>().reverse(lat: lat, lng: lng)
          : null;
      if (details == null) return;
      _applyingSuggestion = true;
      addressController.text = details.address;
      mapLat.value = details.lat;
      mapLng.value = details.lng;
    } catch (_) {
    } finally {
      _applyingSuggestion = false;
      isResolvingAddress.value = false;
    }
  }

  String _labelTitle(String value) {
    switch (value) {
      case 'work':
        return AppStrings.labelWork;
      case 'other':
        return AppStrings.labelOther;
      default:
        return AppStrings.labelHome;
    }
  }

  void selectLabel(String title, String value) {
    _label = value;
    labelController.text = title;
    if (nameController.text.trim().isEmpty ||
        labels.any((item) => item.$1 == nameController.text.trim())) {
      nameController.text = title;
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  void openLabelPicker() {
    AppUtils.hideKeyboard();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in labels)
              ListTile(
                title: AppText(text: item.$1),
                onTap: () => selectLabel(item.$1, item.$2),
              ),
          ],
        ),
      ),
    );
  }

  void onSearchChanged(String value) {
    if (_applyingSuggestion) return;
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      if (pickTarget == LocationPickTarget.drop) {
        _loadRecentDestinations();
      } else {
        suggestions.clear();
      }
      isSearchingPlaces.value = false;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchPlaces(query);
    });
  }

  Future<void> _loadRecentDestinations() async {
    if (!Get.isRegistered<RideRepository>()) {
      suggestions.clear();
      return;
    }
    try {
      final items = await Get.find<RideRepository>().fetchRecentDestinations();
      suggestions.assignAll(
        items
            .map(
              (item) => PlaceSuggestion(
                placeId: item.routeLine,
                description: item.routeLine,
                mainText: item.title,
                secondaryText: item.subtitle,
                lat: item.lat,
                lng: item.lng,
              ),
            )
            .toList(growable: false),
      );
    } catch (_) {
      suggestions.clear();
    }
  }

  Future<void> _searchPlaces(String query) async {
    isSearchingPlaces.value = true;
    try {
      List<PlaceSuggestion> items = const [];
      if (Get.isRegistered<PlacesService>()) {
        items = await Get.find<PlacesService>().autocomplete(query);
      }
      if (items.isEmpty && Get.isRegistered<PlacesRepository>()) {
        items = await Get.find<PlacesRepository>().search(query);
      }
      if (searchController.text.trim() != query) return;
      suggestions.assignAll(items);
    } catch (_) {
      suggestions.clear();
    } finally {
      isSearchingPlaces.value = false;
    }
  }

  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    AppUtils.hideKeyboard();
    isSearchingPlaces.value = true;
    try {
      final details = await _detailsFor(suggestion);
      suggestions.clear();
      searchController.clear();
      if (details == null) {
        addressController.text = suggestion.description;
        return;
      }
      _applyingSuggestion = true;
      addressController.text = details.address;
      mapLat.value = details.lat;
      mapLng.value = details.lng;
      _programmaticMove = true;
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(details.lat, details.lng), 16),
      );
      if (isLocationPick) {
        await _confirmPickedLocation();
      }
    } catch (_) {
      addressController.text = suggestion.description;
      suggestions.clear();
    } finally {
      _applyingSuggestion = false;
      isSearchingPlaces.value = false;
    }
  }

  Future<PlaceDetails?> _detailsFor(PlaceSuggestion suggestion) async {
    if (suggestion.hasCoordinates) {
      return PlaceDetails(
        address: suggestion.description,
        lat: suggestion.lat,
        lng: suggestion.lng,
        city: suggestion.secondaryText,
      );
    }
    if (Get.isRegistered<PlacesService>()) {
      final places = Get.find<PlacesService>();
      if (suggestion.placeId.isNotEmpty) {
        final details = await places.details(suggestion.placeId);
        if (details != null) return details;
      }
      if (suggestion.description.isNotEmpty) {
        final geocoded = await places.geocode(suggestion.description);
        if (geocoded != null) return geocoded;
      }
    }
    if (Get.isRegistered<PlacesRepository>() &&
        suggestion.description.isNotEmpty) {
      return Get.find<PlacesRepository>().geocode(suggestion.description);
    }
    return null;
  }

  Future<void> save() async {
    AppUtils.hideKeyboard();
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    if (!isLocationPick && name.isEmpty) {
      AppUtils.showError(AppStrings.enterAddressName);
      return;
    }
    if (address.isEmpty) {
      AppUtils.showError(AppStrings.enterAddress);
      return;
    }

    if (isLocationPick) {
      await _confirmPickedLocation();
      return;
    }

    if (!Get.isRegistered<AddressRepository>()) {
      AppUtils.showSuccess(
        isEditing ? AppStrings.addressUpdated : AppStrings.addressSaved,
      );
      Get.back();
      return;
    }

    try {
      isLoading.value = true;
      final repo = Get.find<AddressRepository>();
      final saved = isEditing
          ? await runApi(
              () => repo.updateAddress(
                id: editing!.id,
                label: _label,
                name: name,
                address: address,
                lat: mapLat.value,
                lng: mapLng.value,
              ),
            )
          : await runApi(
              () => repo.createAddress(
                label: _label,
                name: name,
                address: address,
                lat: mapLat.value,
                lng: mapLng.value,
              ),
            );
      if (saved == null) return;
      if (Get.isRegistered<SavedAddressesController>()) {
        await Get.find<SavedAddressesController>().loadAddresses();
      }
      Get.back();
      AppUtils.showSuccess(
        isEditing ? AppStrings.addressUpdated : AppStrings.addressSaved,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _confirmPickedLocation() async {
    final target = pickTarget;
    if (target == null) return;
    var address = addressController.text.trim();
    if (address.isEmpty) {
      AppUtils.showError(AppStrings.enterAddress);
      return;
    }
    var lat = mapLat.value;
    var lng = mapLng.value;
    if (lat == 0 && lng == 0) {
      PlaceDetails? details;
      if (Get.isRegistered<PlacesService>()) {
        details = await Get.find<PlacesService>().geocode(address);
      }
      details ??= Get.isRegistered<PlacesRepository>()
          ? await Get.find<PlacesRepository>().geocode(address)
          : null;
      if (details != null) {
        address = details.address;
        lat = details.lat;
        lng = details.lng;
        mapLat.value = lat;
        mapLng.value = lng;
      }
    }
    if (lat == 0 && lng == 0) {
      AppUtils.showError(AppStrings.enterAddress);
      return;
    }
    final parsed = RideLocation.fromAddress(address);
    final location = RideLocation(
      title: parsed.title,
      subtitle: parsed.subtitle,
      lat: lat,
      lng: lng,
    );
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().applyPickedLocation(target, location);
    }
    await _savePickedAddress(
      name: parsed.title.isNotEmpty
          ? parsed.title
          : (target == LocationPickTarget.pickup
                ? AppStrings.pickupLocation
                : AppStrings.dropLocation),
      address: address,
      lat: lat,
      lng: lng,
    );
    Get.back();
  }

  Future<void> _savePickedAddress({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) async {
    if (!Get.isRegistered<AddressRepository>()) return;
    isLoading.value = true;
    try {
      await runApi(
        () => Get.find<AddressRepository>().createAddress(
          label: 'other',
          name: name,
          address: address,
          lat: lat,
          lng: lng,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _mapDebounce?.cancel();
    mapController?.dispose();
    nameController.dispose();
    addressController.dispose();
    labelController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
