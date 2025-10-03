import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/utils/storage.dart';
import 'package:therepist/utils/toaster.dart';

class RegisterCtrl extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final clinicCtrl = TextEditingController();
  final specialtyCtrl = TextEditingController();

  var isLoading = false.obs, isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> register() async {
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
    isLoading.value = true;
    try {
      final request = {
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'clinic': clinicCtrl.text.trim(),
        'specialty': specialtyCtrl.text.trim(),
      };
      await write(AppSession.token, DateTime.now().toIso8601String());
      await write(AppSession.userData, request);
      toaster.success("Congratulation, Registration successfully done.");
      // Get.back();
      emailCtrl.clear();
      passwordCtrl.clear();
      mobileCtrl.clear();
      clinicCtrl.clear();
      specialtyCtrl.clear();
      Get.toNamed(AppRouteNames.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
