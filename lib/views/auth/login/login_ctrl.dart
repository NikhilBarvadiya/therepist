import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/utils/service/notification_service.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';

class LoginCtrl extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  var isLoading = false.obs, isForgotPasswordLoading = false.obs, isPasswordVisible = false.obs;

  AuthService get authService => Get.find<AuthService>();

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
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
    isLoading.value = true;
    try {
      String? fcmToken = await notificationService.getToken();
      final request = {'email': emailCtrl.text.trim(), 'password': passwordCtrl.text.trim(), 'fcmToken': fcmToken ?? ""};
      await authService.login(request);
    } finally {
      emailCtrl.clear();
      passwordCtrl.clear();
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (emailCtrl.text.isEmpty) {
      toaster.warning('Please enter your email');
      return;
    }
    if (!GetUtils.isEmail(emailCtrl.text.trim())) {
      toaster.warning('Please enter a valid email');
      return;
    }
    isForgotPasswordLoading.value = true;
    try {
      final response = await authService.forgotPassword({'email': emailCtrl.text.trim()});
      if (response != null) {
        toaster.success('Password reset link sent to your email');
      }
    } catch (e) {
      toaster.error('Failed to send reset link: ${e.toString()}');
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(AppRouteNames.register);
}
