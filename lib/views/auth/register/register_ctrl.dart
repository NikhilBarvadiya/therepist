import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/utils/service/location_service.dart';
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
  var coordinates = [0.0, 0.0].obs;
  var practitionerType = 'Regular'.obs;

  AuthService get authService => Get.find<AuthService>();

  LocationService get locationService => Get.find<LocationService>();

  var services = <ServiceModel>[].obs, equipment = <ServiceModel>[].obs;
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
    try {
      isGettingLocation(true);
      final addressData = await locationService.getCurrentAddress();
      if (addressData != null) {
        addressCtrl.text = addressData['address'] ?? '';
        coordinates.value = [addressData['latitude'] ?? 0.0, addressData['longitude'] ?? 0.0];
        toaster.success('Location fetched successfully');
      }
    } catch (e) {
      toaster.error('Failed to fetch location: ${e.toString()}');
    } finally {
      isGettingLocation(false);
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
        'coordinates': coordinates,
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
