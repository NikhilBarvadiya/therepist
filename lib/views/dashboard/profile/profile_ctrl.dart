import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:therepist/models/models.dart';

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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController clinicAddressController = TextEditingController();

  final storage = GetStorage();

  @override
  void onInit() {
    _loadUserData();
    super.onInit();
  }

  void _loadUserData() {
    nameController.text = user.value.name;
    emailController.text = user.value.email;
    mobileController.text = user.value.mobile;
    specialtyController.text = user.value.specialty;
    experienceController.text = user.value.experienceYears.toString();
    clinicNameController.text = user.value.clinicName;
    clinicAddressController.text = user.value.clinicAddress;
  }

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) {
      _loadUserData();
    }
    update();
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
      await storage.write('userData', request);
      await storage.write('token', DateTime.now().toIso8601String());
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void logout() async {
    try {
      await storage.remove('token');
      await storage.remove('userData');
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void deleteAccount() async {
    try {
      await storage.remove('token');
      await storage.remove('userData');
      user.value = UserModel(id: '', name: '', email: '', mobile: '', password: '', specialty: '', experienceYears: 0, clinicName: '', clinicAddress: '');
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
