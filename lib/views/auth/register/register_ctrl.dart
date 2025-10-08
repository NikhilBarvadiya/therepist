import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';
import '../../../models/service_model.dart';

class RegisterCtrl extends GetxController {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final clinicCtrl = TextEditingController();
  final specialtyCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();

  var isLoading = false.obs, isPasswordVisible = false.obs, isGettingLocation = false.obs;
  var coordinates = '["0.0", "0.0"]'.obs, locationStatus = 'Fetching location...'.obs;
  var practitionerType = 'Regular'.obs;

  AuthService get authService => Get.find<AuthService>();

  var services = <ServiceModel>[].obs;
  var equipment = <ServiceModel>[].obs;
  var selectedServices = <ServiceModel>[].obs, selectedEquipment = <ServiceModel>[].obs;

  @override
  void onInit() {
    _fetchCurrentLocation();
    super.onInit();
  }

  void setPractitionerType(String type) {
    practitionerType.value = type;
  }

  Future<void> retryLocation() async => await _fetchCurrentLocation();

  Future<void> _fetchCurrentLocation() async {
    isGettingLocation.value = true;
    locationStatus.value = 'Checking location permissions...';
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationStatus.value = 'Location services disabled';
        toaster.warning('Please enable location services for better experience');
        isGettingLocation.value = false;
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        locationStatus.value = 'Requesting location permission...';
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationStatus.value = 'Location permission denied';
          toaster.warning('Location permission is required for better service');
          isGettingLocation.value = false;
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        locationStatus.value = 'Location permission permanently denied';
        toaster.warning('Please enable location permissions in app settings');
        isGettingLocation.value = false;
        return;
      }
      locationStatus.value = 'Getting your location...';
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 15));
      coordinates.value = '["${position.latitude}", "${position.longitude}"]';
      locationStatus.value = 'Location fetched successfully!';
    } catch (e) {
      locationStatus.value = 'Failed to get location';
      toaster.error('Location error: ${e.toString()}');
    } finally {
      isGettingLocation.value = false;
    }
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void updateSelectedServices(List<ServiceModel> newSelection) => selectedServices.assignAll(newSelection);

  void updateSelectedEquipment(List<ServiceModel> newSelection) => selectedEquipment.assignAll(newSelection);

  Future<void> register() async {
    if (nameCtrl.text.isEmpty) {
      return toaster.warning('Please enter your name');
    }
    if (emailCtrl.text.isEmpty) {
      return toaster.warning('Please enter your email');
    }
    if (!GetUtils.isEmail(emailCtrl.text)) {
      return toaster.warning('Please enter a valid email');
    }
    if (passwordCtrl.text.isEmpty) {
      return toaster.warning('Please enter your password');
    }
    if (passwordCtrl.text.length < 6) {
      return toaster.warning('Password must be at least 6 characters');
    }
    if (mobileCtrl.text.isEmpty) {
      return toaster.warning('Please enter your mobile number');
    }
    if (!GetUtils.isPhoneNumber(mobileCtrl.text)) {
      return toaster.warning('Please enter a valid mobile number');
    }
    if (clinicCtrl.text.isEmpty) {
      return toaster.warning('Please enter your clinic name');
    }
    if (specialtyCtrl.text.isEmpty) {
      return toaster.warning('Please enter the specialty');
    }
    if (experienceCtrl.text.isEmpty) {
      return toaster.warning('Please enter your experience');
    }
    final experience = int.tryParse(experienceCtrl.text);
    if (experience == null || experience < 0 || experience > 50) {
      return toaster.warning('Please enter valid experience (0-50 years)');
    }
    if (selectedServices.isEmpty) {
      return toaster.warning('Please select at least one service');
    }
    if (selectedEquipment.isEmpty) {
      return toaster.warning('Please select at least one equipment');
    }
    if (addressCtrl.text.isEmpty) {
      return toaster.warning('Please enter your address');
    }

    isLoading.value = true;
    try {
      List servicesIds = selectedServices.map((e) => {"id": e.id}).toList();
      List equipmentIds = selectedEquipment.map((e) => {"id": e.id}).toList();
      final request = {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'clinicName': clinicCtrl.text.trim(),
        'specialties': [specialtyCtrl.text.trim()],
        'experience': experience,
        'type': practitionerType.value,
        'address': addressCtrl.text.trim(),
        'coordinates': coordinates.value,
        'services': servicesIds,
        'equipment': equipmentIds,
      };
      await authService.register(request);
    } finally {
      nameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();
      mobileCtrl.clear();
      clinicCtrl.clear();
      specialtyCtrl.clear();
      experienceCtrl.clear();
      practitionerType.value = 'Regular';
      selectedServices.clear();
      selectedEquipment.clear();
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
