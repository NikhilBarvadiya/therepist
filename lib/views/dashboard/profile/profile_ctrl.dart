import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/models/models.dart';
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/helper.dart';
import 'package:therepist/utils/storage.dart';
import 'package:therepist/views/dashboard/dashboard_ctrl.dart';

class ProfileCtrl extends GetxController {
  var user = UserModel(
    id: '1',
    name: 'Dr. John Smith',
    email: 'john.smith@example.com',
    mobile: '+91 98765 43210',
    password: '********',
    specialty: 'Orthopedic Physiotherapy',
    experienceYears: 10,
    clinicName: 'Smith Physiotherapy Clinic',
    clinicAddress: '123, Palm Street, Adajan, Surat, Gujarat, 395009',
  ).obs;

  bool isEditMode = false;

  var notificationRange = 8.obs;
  var notificationsEnabled = false.obs;
  var availableDays = <String>[].obs;
  var daySchedules = <String, List<Map<String, TimeOfDay>>>{}.obs;

  var avatar = Rx<File?>(null);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController clinicAddressController = TextEditingController();

  final weekDays = [
    {'name': 'Monday', 'key': 'mon'},
    {'name': 'Tuesday', 'key': 'tue'},
    {'name': 'Wednesday', 'key': 'wed'},
    {'name': 'Thursday', 'key': 'thu'},
    {'name': 'Friday', 'key': 'fri'},
    {'name': 'Saturday', 'key': 'sat'},
    {'name': 'Sunday', 'key': 'sun'},
  ];

  @override
  void onInit() {
    _loadUserData();
    _initializeAvailability();
    super.onInit();
  }

  Future<void> _loadUserData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      notificationRange.value = userData["notificationRange"] ?? 8;
      user.value = UserModel(
        id: "1",
        name: userData["name"] ?? 'Dr. John Smith',
        email: userData["email"] ?? 'john.smith@example.com',
        mobile: userData["mobile"] ?? '+91 98765 43210',
        password: userData["password"] ?? '********',
        specialty: userData["specialty"] ?? 'Orthopedic Physiotherapy',
        experienceYears: userData["experienceYears"] ?? 10,
        clinicName: userData["clinicName"] ?? "Smith Physiotherapy Clinic",
        clinicAddress: userData["clinicAddress"] ?? '123, Palm Street, Adajan, Surat, Gujarat, 395009',
      );
      if (userData['availableDays'] != null) {
        availableDays.assignAll(List<String>.from(userData['availableDays']));
      }
      if (userData['daySchedules'] != null) {
        final schedulesMap = userData['daySchedules'] as Map<String, dynamic>;
        schedulesMap.forEach((day, slots) {
          daySchedules[day] = (slots as List).map((slot) {
            final startParts = (slot['start'] as String).split(':');
            final endParts = (slot['end'] as String).split(':');
            return {'start': TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1])), 'end': TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]))};
          }).toList();
        });
      }
    }
    nameController.text = user.value.name;
    emailController.text = user.value.email;
    mobileController.text = user.value.mobile;
    specialtyController.text = user.value.specialty;
    experienceController.text = user.value.experienceYears.toString();
    clinicNameController.text = user.value.clinicName;
    clinicAddressController.text = user.value.clinicAddress;
  }

  void _initializeAvailability() {
    availableDays.addAll(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']);
    for (final day in weekDays) {
      daySchedules[day['name']!] = [
        {'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
      ];
    }
  }

  void setNotificationRange(int range) {
    notificationRange.value = range;
  }

  Future<void> saveNotificationRange() async {
    final userData = await read(AppSession.userData) ?? {};
    userData['notificationRange'] = notificationRange.value;
    await write(AppSession.userData, userData);
  }

  Future<void> saveAvailability() async {
    final userData = await read(AppSession.userData) ?? {};
    userData['availableDays'] = availableDays.toList();
    final schedulesMap = <String, dynamic>{};
    daySchedules.forEach((day, slots) {
      schedulesMap[day] = slots.map((slot) => {'start': '${slot['start']!.hour}:${slot['start']!.minute}', 'end': '${slot['end']!.hour}:${slot['end']!.minute}'}).toList();
    });
    userData['daySchedules'] = schedulesMap;
    await write(AppSession.userData, userData);
  }

  void toggleDayAvailability(String day, bool isAvailable) {
    if (isAvailable) {
      availableDays.add(day);
    } else {
      availableDays.remove(day);
    }
    saveAvailability();
    update();
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
    saveAvailability();
  }

  void updateSlotTime(String day, int slotIndex, String type, TimeOfDay time) {
    if (daySchedules[day] != null && slotIndex < daySchedules[day]!.length) {
      final updatedSlots = List<Map<String, TimeOfDay>>.from(daySchedules[day]!);
      updatedSlots[slotIndex][type] = time;
      daySchedules[day] = updatedSlots;
      saveAvailability();
    }
  }

  void removeTimeSlot(String day, int slotIndex) {
    if (daySchedules[day] != null && daySchedules[day]!.length > 1) {
      final updatedSlots = List<Map<String, TimeOfDay>>.from(daySchedules[day]!)..removeAt(slotIndex);
      daySchedules[day] = updatedSlots;
      saveAvailability();
    }
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    int totalMinutes = time.hour * 60 + time.minute + minutes;
    int newHour = (totalMinutes ~/ 60) % 24;
    int newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) {
      _loadUserData();
    }
    update();
  }

  Future<void> pickAvatar() async {
    final result = await helper.pickImage();
    if (result != null) {
      avatar.value = result;
    }
  }

  void saveProfile() {
    if (_validateForm()) {
      updateProfile(
        name: nameController.text,
        email: emailController.text,
        mobile: mobileController.text,
        specialty: specialtyController.text,
        experienceYears: int.parse(experienceController.text),
        clinicName: clinicNameController.text,
        clinicAddress: clinicAddressController.text,
      );
      isEditMode = false;
      update();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 12,
      );
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        mobileController.text.isEmpty ||
        specialtyController.text.isEmpty ||
        experienceController.text.isEmpty ||
        clinicNameController.text.isEmpty ||
        clinicAddressController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      Get.snackbar('Error', 'Invalid email format', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(mobileController.text)) {
      Get.snackbar('Error', 'Invalid mobile number', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (int.tryParse(experienceController.text) == null) {
      Get.snackbar('Error', 'Enter a valid number for experience', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    return true;
  }

  void updateProfile({
    required String name,
    required String email,
    required String mobile,
    required String specialty,
    required int experienceYears,
    required String clinicName,
    required String clinicAddress,
  }) async {
    try {
      user.value = UserModel(
        id: user.value.id,
        name: name,
        email: email,
        mobile: mobile,
        password: user.value.password,
        specialty: specialty,
        experienceYears: experienceYears,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
      );
      final request = {
        'name': name,
        'email': email,
        'password': user.value.password,
        'mobile': mobile,
        'specialty': specialty,
        'experienceYears': experienceYears,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
      };
      await write(AppSession.token, DateTime.now().toIso8601String());
      await write(AppSession.userData, request);
      final ctrl = Get.find<DashboardCtrl>();
      ctrl.loadUserData();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void logout() async {
    try {
      await clearStorage();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void deleteAccount() async {
    try {
      await clearStorage();
      user.value = UserModel(id: '', name: '', email: '', mobile: '', password: '', specialty: '', experienceYears: 0, clinicName: '', clinicAddress: '');
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
