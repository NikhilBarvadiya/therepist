import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/models/models.dart';
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
  var services = <ServiceModel>[
    ServiceModel(
      id: 1,
      name: 'Ortho',
      description: 'Comprehensive rehabilitation for joint and muscle injuries, focusing on strength and mobility.',
      icon: Icons.fitness_center,
      isActive: true,
    ),
    ServiceModel(id: 2, name: 'Neuro', description: 'Specialized therapy for neurological conditions to enhance motor skills and coordination.', icon: Icons.psychology, isActive: false),
    ServiceModel(id: 3, name: 'Sports', description: 'Tailored recovery programs for athletes to regain peak performance post-injury.', icon: Icons.sports_tennis, isActive: true),
    ServiceModel(id: 4, name: 'Maternity', description: 'Supportive exercises for prenatal and postnatal care to promote maternal health.', icon: Icons.pregnant_woman, isActive: true),
    ServiceModel(id: 5, name: 'Fitness', description: 'Personalized fitness plans to improve strength, flexibility, and overall wellness.', icon: Icons.directions_run, isActive: false),
    ServiceModel(id: 6, name: 'Geriatric', description: 'Gentle therapy for elderly patients to improve mobility and reduce pain.', icon: Icons.elderly, isActive: true),
    ServiceModel(id: 7, name: 'Pediatric', description: 'Therapy for children to support developmental and physical milestones.', icon: Icons.child_care, isActive: true),
    ServiceModel(id: 8, name: 'Pain Management', description: 'Advanced techniques to alleviate chronic pain and improve quality of life.', icon: Icons.healing, isActive: false),
  ].obs;
  var equipment = <ServiceModel>[
    ServiceModel(id: 1, name: 'Cupping', description: 'Suction-based therapy to promote blood flow and relieve muscle tension.', icon: Icons.spa, isActive: true),
    ServiceModel(id: 2, name: 'Tapping', description: 'Percussive therapy to stimulate muscles and improve circulation.', icon: Icons.touch_app, isActive: true),
    ServiceModel(id: 3, name: 'Needling', description: 'Dry needling to target trigger points and alleviate pain.', icon: Icons.medical_services, isActive: true),
    ServiceModel(id: 4, name: 'Laser', description: 'Low-level laser therapy for pain relief and tissue repair.', icon: Icons.light, isActive: true),
    ServiceModel(id: 5, name: 'Tens', description: 'Transcutaneous electrical nerve stimulation for pain management.', icon: Icons.electrical_services, isActive: true),
    ServiceModel(id: 6, name: 'Ift', description: 'Interferential therapy for deep tissue pain relief and muscle stimulation.', icon: Icons.vibration, isActive: true),
  ].obs;
  var selectedServices = <ServiceModel>[].obs, selectedEquipment = <ServiceModel>[].obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void updateSelectedServices(List<ServiceModel> newSelection) {
    selectedServices.assignAll(newSelection);
  }

  void updateSelectedEquipment(List<ServiceModel> newSelection) {
    selectedEquipment.assignAll(newSelection);
  }

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
    if (selectedServices.isEmpty) {
      return toaster.warning('Please select at least one service');
    }
    if (selectedEquipment.isEmpty) {
      return toaster.warning('Please select at least one equipment');
    }
    isLoading.value = true;
    try {
      final request = {
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'clinic': clinicCtrl.text.trim(),
        'specialty': specialtyCtrl.text.trim(),
        'services': selectedServices.map((e) => e.name).toList(),
        'equipment': selectedEquipment.map((e) => e.name).toList(),
      };
      await write(AppSession.token, DateTime.now().toIso8601String());
      await write(AppSession.userData, request);
      toaster.success("Congratulations, Registration successfully completed.");
      emailCtrl.clear();
      passwordCtrl.clear();
      mobileCtrl.clear();
      clinicCtrl.clear();
      specialtyCtrl.clear();
      selectedServices.clear();
      selectedEquipment.clear();
      Get.toNamed(AppRouteNames.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
