import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart' as path;
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/helper.dart';
import 'package:therepist/utils/storage.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';
import 'package:therepist/views/dashboard/home/home_ctrl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/user_model.dart';

class ProfileCtrl extends GetxController {
  var user = UserModel(
    id: '',
    name: '',
    email: '',
    mobile: '',
    password: '',
    specialty: '',
    experienceYears: 0,
    clinicName: '',
    clinicAddress: '',
    avatar: '',
    type: 'Regular',
    notificationRange: 8,
    workingDays: [],
    services: [],
    equipment: [],
    location: LocationModel(address: '', coordinates: [0.0, 0.0]),
  ).obs;

  var isLoading = false.obs, isSaving = false.obs, isGettingLocation = false.obs;
  var isCurrentPasswordVisible = false.obs, isNewPasswordVisible = false.obs, isConfirmPasswordVisible = false.obs;
  var isEditMode = false;
  var coordinates = [0.0, 0.0].obs, locationStatus = 'Fetching location...'.obs;

  var avatar = Rx<File?>(null);
  var notificationRange = 8.obs;
  var availableDays = <String>[].obs;
  var daySchedules = <String, List<Map<String, TimeOfDay>>>{}.obs;
  final weekDays = [
    {'name': 'Monday', 'key': 'mon'},
    {'name': 'Tuesday', 'key': 'tue'},
    {'name': 'Wednesday', 'key': 'wed'},
    {'name': 'Thursday', 'key': 'thu'},
    {'name': 'Friday', 'key': 'fri'},
    {'name': 'Saturday', 'key': 'sat'},
    {'name': 'Sunday', 'key': 'sun'},
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController clinicAddressController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
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
      coordinates.value = [position.latitude, position.longitude];
      locationStatus.value = 'Location fetched successfully!';
      final request = {'coordinates': coordinates};
      dio.FormData formData = dio.FormData.fromMap(request);
      await _authService.updateProfile(formData);
    } catch (e) {
      locationStatus.value = 'Failed to get location';
      toaster.error('Location error: ${e.toString()}');
    } finally {
      isGettingLocation.value = false;
    }
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final response = await _authService.getProfile();
      if (response != null) {
        _parseUserData(response);
        _updateControllers();
        _loadAvailabilityFromApi(response);
        await write(AppSession.userData, response);
        final homeCtrl = Get.find<HomeCtrl>();
        homeCtrl.getUserProfile();
      } else {
        await _loadLocalData();
      }
    } catch (e) {
      toaster.error('Error loading profile: ${e.toString()}');
      await _loadLocalData();
    } finally {
      isLoading.value = false;
    }
  }

  void _parseUserData(Map<String, dynamic> data) {
    List<double> coordinates = [];
    final locationData = data['location'];
    if (locationData != null && locationData['coordinates'] is List) {
      coordinates = (locationData['coordinates'] as List).map<double>((e) {
        if (e is double) return e;
        if (e is int) return e.toDouble();
        if (e is num) return e.toDouble();
        return 0.0;
      }).toList();
    }
    if (coordinates.isEmpty) {
      coordinates = [0.0, 0.0];
    }
    user.value = UserModel(
      id: data['_id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      password: data["password"] ?? '********',
      specialty: data['specialties'] != null && data['specialties'] != 0 ? data['specialties'][0]['name'] ?? '' : '',
      experienceYears: data['experience'] ?? 0,
      clinicName: data['clinicName'] ?? '',
      clinicAddress: data['location'] != null ? data['location']['address'] ?? '' : '',
      avatar: data['avatar'] ?? '',
      type: data['type'] ?? 'Regular',
      notificationRange: data['notificationRange'] ?? 8,
      workingDays: List<Map<String, dynamic>>.from(data['workingDays'] ?? []),
      services: List<Map<String, dynamic>>.from(data['services'] ?? []),
      equipment: List<Map<String, dynamic>>.from(data['equipment'] ?? []),
      location: LocationModel(address: data['location'] != null ? data['location']['address'] ?? '' : '', coordinates: coordinates.isNotEmpty ? coordinates : [0.0, 0.0]),
    );
    notificationRange.value = user.value.notificationRange;
  }

  Future<void> _loadLocalData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      _parseUserData(userData);
      _updateControllers();
    }
  }

  void _updateControllers() {
    nameController.text = user.value.name;
    emailController.text = user.value.email;
    mobileController.text = user.value.mobile;
    specialtyController.text = user.value.specialty;
    experienceController.text = user.value.experienceYears.toString();
    clinicNameController.text = user.value.clinicName;
    clinicAddressController.text = user.value.clinicAddress;
  }

  void setNotificationRange(int range) => notificationRange.value = range;

  void toggleCurrentPasswordVisibility() => isCurrentPasswordVisible.toggle();

  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();

  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) {
      _updateControllers();
    }
    update();
  }

  Future<void> pickAvatar() async {
    final result = await helper.pickImage();
    if (result != null) {
      avatar.value = result;
      dio.FormData formData = dio.FormData.fromMap({});
      formData.files.add(MapEntry('profileImage', await dio.MultipartFile.fromFile(avatar.value!.path, filename: path.basename(avatar.value!.path))));
      await _authService.updateProfile(formData);
    }
  }

  Future<void> saveProfile() async {
    if (!_validateForm()) return;
    try {
      isSaving.value = true;
      final request = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'specialty': specialtyController.text.trim(),
        'experience': int.tryParse(experienceController.text.trim()) ?? 0,
        'clinicName': clinicNameController.text.trim(),
        'clinicAddress': clinicAddressController.text.trim(),
        'notificationRange': notificationRange.value,
        'type': user.value.type,
        'address': user.value.location.address,
        'coordinates': user.value.location.coordinates,
      };
      dio.FormData formData = dio.FormData.fromMap(request);
      final response = await _authService.updateProfile(formData);
      if (response != null) {
        await write(AppSession.userData, response);
        _loadLocalData();
        isEditMode = false;
        toaster.success('Profile updated successfully');
        final homeCtrl = Get.find<HomeCtrl>();
        homeCtrl.getUserProfile();
      }
    } catch (e) {
      toaster.error('Error updating profile: ${e.toString()}');
    } finally {
      isSaving.value = false;
      update();
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      toaster.warning('Please enter your name');
      return false;
    }
    if (emailController.text.isEmpty) {
      toaster.warning('Please enter your email');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      toaster.warning('Please enter a valid email address');
      return false;
    }
    if (mobileController.text.isEmpty) {
      toaster.warning('Please enter your mobile number');
      return false;
    }
    if (!GetUtils.isPhoneNumber(mobileController.text)) {
      toaster.warning('Please enter a valid mobile number');
      return false;
    }
    if (specialtyController.text.isEmpty) {
      toaster.warning('Please enter your specialty');
      return false;
    }
    if (experienceController.text.isEmpty) {
      toaster.warning('Please enter your experience');
      return false;
    }
    final experience = int.tryParse(experienceController.text);
    if (experience == null || experience < 0 || experience > 50) {
      toaster.warning('Please enter valid experience (0-50 years)');
      return false;
    }
    if (clinicNameController.text.isEmpty) {
      toaster.warning('Please enter your clinic name');
      return false;
    }
    if (clinicAddressController.text.isEmpty) {
      toaster.warning('Please enter your clinic address');
      return false;
    }
    return true;
  }

  Future<void> changePassword() async {
    if (!_validatePasswordForm()) return;
    try {
      isSaving.value = true;
      final request = {'oldPassword': currentPasswordController.text.trim(), 'newPassword': newPasswordController.text.trim()};
      final response = await _authService.updatePassword(request);
      if (response != null) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        isCurrentPasswordVisible.value = false;
        isNewPasswordVisible.value = false;
        isConfirmPasswordVisible.value = false;
        toaster.success('Password updated successfully');
        if (Get.isDialogOpen ?? false) {
          Get.close(1);
        }
      }
    } catch (e) {
      toaster.error('Error updating password: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  bool _validatePasswordForm() {
    if (currentPasswordController.text.isEmpty) {
      toaster.warning('Please enter your current password');
      return false;
    }
    if (newPasswordController.text.isEmpty) {
      toaster.warning('Please enter new password');
      return false;
    }
    if (newPasswordController.text.length < 6) {
      toaster.warning('New password must be at least 6 characters');
      return false;
    }
    if (confirmPasswordController.text.isEmpty) {
      toaster.warning('Please confirm your new password');
      return false;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      toaster.warning('New passwords do not match');
      return false;
    }
    if (currentPasswordController.text == newPasswordController.text) {
      toaster.warning('New password must be different from current password');
      return false;
    }
    return true;
  }

  Future<void> updateNotificationRange() async {
    try {
      final request = {'notificationRange': notificationRange.value};
      dio.FormData formData = dio.FormData.fromMap(request);
      final response = await _authService.updateProfile(formData);
      if (response != null) {
        await write(AppSession.userData, response);
        user.value = user.value.copyWith(notificationRange: notificationRange.value);
        toaster.success('Notification range updated');
      } else {
        notificationRange.value = user.value.notificationRange;
      }
    } catch (e) {
      toaster.error('Error updating notification range: ${e.toString()}');
      notificationRange.value = user.value.notificationRange;
    }
  }

  Future<void> logout() async {
    try {
      await clearStorage();
      update();
    } catch (e) {
      toaster.error('Error during logout: ${e.toString()}');
    }
  }

  Future<void> openPrivacyPolicy() async {
    try {
      final url = "https://sites.google.com/view/healup-privacy-policy/home";
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      toaster.error('Error: $e');
    }
  }

  void openTermsOfService() async {
    try {
      final url = "https://itfuturz.in/support/healup-patient-support.html";
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      toaster.error('Error: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await clearStorage();
      helper.launchURL("https://docs.google.com/forms/d/e/1FAIpQLSe_6UsyVHh5hX02k2N-uaAz26Kl9iTim2fTskkyppcthKmlDQ/viewform?pli=1");
      update();
    } catch (e) {
      toaster.error('Error deleting account: ${e.toString()}');
    }
  }

  List<Map<String, TimeOfDay>> getTimeSlotsForDay(String day) {
    return daySchedules[day] ?? [];
  }

  void addTimeSlot(String day) {
    if (daySchedules[day] == null) {
      daySchedules[day] = [];
    }
    final lastSlot = daySchedules[day]!.isNotEmpty ? daySchedules[day]!.last : null;
    final startTime = lastSlot != null ? _addMinutes(lastSlot['end']!, 5) : const TimeOfDay(hour: 9, minute: 0);
    final endTime = _addMinutes(startTime, 60);
    final updatedSlots = List<Map<String, TimeOfDay>>.from(daySchedules[day]!)..add({'start': startTime, 'end': endTime});
    daySchedules[day] = updatedSlots;
    update();
  }

  void updateSlotTime(String day, int slotIndex, String type, TimeOfDay time) {
    if (daySchedules[day] != null && slotIndex < daySchedules[day]!.length) {
      final updatedSlots = List<Map<String, TimeOfDay>>.from(daySchedules[day]!);
      updatedSlots[slotIndex][type] = time;
      daySchedules[day] = updatedSlots;
      update();
    }
  }

  void removeTimeSlot(String day, int slotIndex) {
    if (daySchedules[day] != null && daySchedules[day]!.length > 1) {
      final updatedSlots = List<Map<String, TimeOfDay>>.from(daySchedules[day]!)..removeAt(slotIndex);
      daySchedules[day] = updatedSlots;
      update();
    }
  }

  Map<String, dynamic> _convertToApiFormat() {
    final workingDays = <Map<String, dynamic>>[];
    for (final day in weekDays) {
      final dayName = day['name']!;
      final isEnabled = availableDays.contains(dayName);
      final slots = getTimeSlotsForDay(dayName);
      final daySlots = slots.map((slot) {
        return {'from': _formatTimeForApi(slot['start']!), 'to': _formatTimeForApi(slot['end']!)};
      }).toList();
      workingDays.add({'day': dayName, 'enabled': isEnabled, 'slots': daySlots});
    }
    return {'workingDays': workingDays};
  }

  String _formatTimeForApi(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> saveAvailability() async {
    try {
      isSaving.value = true;
      final request = _convertToApiFormat();
      final response = await _authService.updateWorkingDays(request);
      if (response != null) {
        final userData = await read(AppSession.userData) ?? {};
        userData['workingDays'] = availableDays.toList();
        final schedulesMap = <String, dynamic>{};
        daySchedules.forEach((day, slots) {
          schedulesMap[day] = slots.map((slot) => {'start': '${slot['start']!.hour}:${slot['start']!.minute}', 'end': '${slot['end']!.hour}:${slot['end']!.minute}'}).toList();
        });
        userData['daySchedules'] = schedulesMap;
        await write(AppSession.userData, userData);
        toaster.success('Working days updated successfully');
      }
    } catch (e) {
      toaster.error('Error updating working days: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  void _loadAvailabilityFromApi(Map<String, dynamic> userData) {
    try {
      availableDays.clear();
      daySchedules.clear();
      if (userData['workingDays'] != null && userData['workingDays'] is List) {
        final apiWorkingDays = userData['workingDays'] as List;
        for (final dayData in apiWorkingDays) {
          final dayName = dayData['day'];
          final isEnabled = dayData['enabled'] ?? false;
          final slots = dayData['slots'] ?? [];
          if (isEnabled) {
            availableDays.add(dayName);
          }
          final timeSlots = slots.map<Map<String, TimeOfDay>>((slot) {
            final fromParts = (slot['from'] as String).split(':');
            final toParts = (slot['to'] as String).split(':');

            return {'start': TimeOfDay(hour: int.parse(fromParts[0]), minute: int.parse(fromParts[1])), 'end': TimeOfDay(hour: int.parse(toParts[0]), minute: int.parse(toParts[1]))};
          }).toList();
          daySchedules[dayName] = timeSlots;
        }
      } else {
        _initializeDefaultAvailability();
      }
    } catch (e) {
      _initializeDefaultAvailability();
    }
  }

  void _initializeDefaultAvailability() {
    availableDays.addAll(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']);
    for (final day in weekDays) {
      daySchedules[day['name']!] = [
        {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
      ];
    }
  }

  void toggleDayAvailability(String day, bool isAvailable) {
    if (isAvailable) {
      availableDays.add(day);
    } else {
      availableDays.remove(day);
    }
    update();
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    int totalMinutes = time.hour * 60 + time.minute + minutes;
    int newHour = (totalMinutes ~/ 60) % 24;
    int newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    specialtyController.dispose();
    experienceController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
