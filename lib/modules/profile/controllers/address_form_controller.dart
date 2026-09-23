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

  /// Pick mode: the place the rider actually selected (suggestion, recent
  /// destination, current location, or the existing pickup/drop being
  /// re-edited). Confirm is only possible with one – typed text is not.
  final pickedLocation = Rxn<RideLocation>();
  final isLocating = false.obs;
  bool _pickedIsCurrent = false;

  /// Bumped by every selection / reverse-geocode; a stale in-flight
  /// `_resolveFromMap` result is dropped instead of overwriting a newer pick.
  int _resolveGeneration = 0;

  /// Places Autocomplete session: created on the first keystroke of a search
  /// and reset after a selection.
  String _sessionToken = '';

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

  /// Pick mode confirm needs a selected place with real coordinates.
  bool get canConfirm {
    if (!isLocationPick) return true;
    final picked = pickedLocation.value;
    return picked != null && picked.hasCoordinates;
  }

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
      // No reverse-geocode of the default map centre here: an empty address
      // keeps a made-up pickup/drop from being confirmed.
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
    if (!current.hasCoordinates) return;
    final line = current.routeLine.trim();
    if (line.isEmpty) return;
    addressController.text = line;
    // Re-editing: start from the current address, cursor at the end.
    searchController.value = TextEditingValue(
      text: line,
      selection: TextSelection.collapsed(offset: line.length),
    );
    mapLat.value = current.lat;
    mapLng.value = current.lng;
    // Same instance: confirming it unchanged does not trigger a re-quote.
    pickedLocation.value = current;
    _pickedIsCurrent =
        target == LocationPickTarget.pickup && home.usingCurrentPickup.value;
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
    final generation = ++_resolveGeneration;
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
      // A suggestion / newer pin was selected meanwhile: keep that one.
      if (details == null || generation != _resolveGeneration) return;
      addressController.text = details.address;
      mapLat.value = details.lat;
      mapLng.value = details.lng;
    } catch (_) {
    } finally {
      if (generation == _resolveGeneration) {
        isResolvingAddress.value = false;
      }
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
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          24 + MediaQuery.viewPaddingOf(Get.context!).bottom,
        ),
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
      isSearchingPlaces.value = false;
      if (pickTarget == LocationPickTarget.drop) {
        _debounce = Timer(
          const Duration(milliseconds: 300),
          _loadRecentDestinations,
        );
      } else {
        suggestions.clear();
      }
      return;
    }
    if (_sessionToken.isEmpty) _sessionToken = PlacesService.newSessionToken();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchPlaces(query);
    });
  }

  /// Search field clear button: clears the query and its suggestions.
  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    suggestions.clear();
    isSearchingPlaces.value = false;
    _sessionToken = '';
  }

  /// Location icon: use the device's current location as the picked place.
  Future<void> useCurrentLocation() async {
    if (isLocating.value || !Get.isRegistered<HomeController>()) return;
    AppUtils.hideKeyboard();
    isLocating.value = true;
    final generation = ++_resolveGeneration;
    try {
      final location = await Get.find<HomeController>().currentDeviceLocation();
      if (generation != _resolveGeneration) return;
      if (location == null || !location.hasCoordinates) {
        AppUtils.showError(AppStrings.currentLocationUnavailable);
        return;
      }
      final address = location.subtitle.trim().isNotEmpty
          ? location.subtitle.trim()
          : location.routeLine;
      addressController.text = address;
      mapLat.value = location.lat;
      mapLng.value = location.lng;
      if (isLocationPick) {
        final isPickup = pickTarget == LocationPickTarget.pickup;
        final parsed = RideLocation.fromAddress(address);
        pickedLocation.value = isPickup
            ? location
            : RideLocation(
                title: parsed.title,
                subtitle: parsed.subtitle,
                lat: location.lat,
                lng: location.lng,
              );
        _pickedIsCurrent = isPickup;
        clearSearch();
      }
      _programmaticMove = true;
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
      );
    } catch (_) {
      // Camera animation failure: the location itself is applied.
    } finally {
      isLocating.value = false;
    }
  }

  Future<void> _loadRecentDestinations() async {
    if (!Get.isRegistered<RideRepository>()) {
      suggestions.clear();
      return;
    }
    final queryAtStart = searchController.text;
    try {
      final items = await Get.find<RideRepository>().fetchRecentDestinations();
      // The rider typed meanwhile: keep the newer results.
      if (searchController.text != queryAtStart) return;
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
        final bias = _searchBias();
        items = await Get.find<PlacesService>().autocomplete(
          query,
          sessionToken: _sessionToken,
          biasLat: bias?.lat,
          biasLng: bias?.lng,
        );
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

  /// Autocomplete bias point: the place being edited, else the trip pickup
  /// (current / chosen pickup), else the saved address being edited.
  RideLocation? _searchBias() {
    final picked = pickedLocation.value;
    if (picked != null && picked.hasCoordinates) return picked;
    if (Get.isRegistered<HomeController>()) {
      final pickup = Get.find<HomeController>().pickup.value;
      if (pickup.hasCoordinates) return pickup;
    }
    if (isEditing && editing!.lat != 0 && editing!.lng != 0) {
      return RideLocation(
        title: '',
        subtitle: '',
        lat: editing!.lat,
        lng: editing!.lng,
      );
    }
    return null;
  }

  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    AppUtils.hideKeyboard();
    _debounce?.cancel();
    // Invalidate any in-flight reverse geocode so it can't overwrite this.
    final generation = ++_resolveGeneration;
    isResolvingAddress.value = false;
    isSearchingPlaces.value = true;
    _applyingSuggestion = true;
    PlaceDetails? details;
    try {
      details = await _detailsFor(suggestion);
    } catch (_) {
      details = null;
    }
    // The autocomplete session ends with the details lookup.
    _sessionToken = '';
    try {
      if (generation != _resolveGeneration) return;
      if (details == null || (details.lat == 0 && details.lng == 0)) {
        // Text and coordinates only change together: keep the previous
        // selection (if any) and never pair this text with stale coords.
        AppUtils.showError(AppStrings.placeDetailsFailed);
        return;
      }
      suggestions.clear();
      searchController.clear();
      addressController.text = details.address;
      mapLat.value = details.lat;
      mapLng.value = details.lng;
      if (isLocationPick) {
        final parsed = RideLocation.fromAddress(details.address);
        pickedLocation.value = RideLocation(
          title: parsed.title,
          subtitle: parsed.subtitle,
          lat: details.lat,
          lng: details.lng,
        );
        _pickedIsCurrent = false;
        await _confirmPickedLocation();
        return;
      }
      _programmaticMove = true;
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(details.lat, details.lng), 16),
      );
    } catch (_) {
      // Camera animation failure: the selection itself is applied.
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
        final details = await places.details(
          suggestion.placeId,
          sessionToken: _sessionToken,
        );
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
    if (isLocationPick) {
      await _confirmPickedLocation();
      return;
    }

    final name = nameController.text.trim();
    final address = addressController.text.trim();
    if (name.isEmpty) {
      AppUtils.showError(AppStrings.enterAddressName);
      return;
    }
    if (address.isEmpty) {
      AppUtils.showError(AppStrings.enterAddress);
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

  /// Pick mode: applies the selected place to the trip. Only a real
  /// selection counts; typed text alone is never geocoded into a location.
  /// Picked pickups/drops are not stored as Saved Addresses.
  Future<void> _confirmPickedLocation() async {
    final target = pickTarget;
    if (target == null) return;
    final picked = pickedLocation.value;
    if (picked == null || !picked.hasCoordinates) {
      AppUtils.showError(AppStrings.selectLocationFromList);
      return;
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().applyPickedLocation(
        target,
        picked,
        isCurrentLocation: _pickedIsCurrent,
      );
    }
    Get.back();
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
