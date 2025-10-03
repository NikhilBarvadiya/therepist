import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/models/models.dart';

class ServicesCtrl extends GetxController {
  var filteredServices = <ServiceModel>[].obs;

  var services = <ServiceModel>[
    ServiceModel(
      id: 1,
      name: 'Ortho',
      description: 'Comprehensive rehabilitation for joint and muscle injuries, focusing on strength and mobility.',
      icon: Icons.fitness_center,
      color: Color(0xFF6C63FF),
      isActive: true,
    ),
    ServiceModel(
      id: 2,
      name: 'Neuro',
      description: 'Specialized therapy for neurological conditions to enhance motor skills and coordination.',
      icon: Icons.psychology,
      color: Color(0xFFFF6584),
      isActive: false,
    ),
    ServiceModel(
      id: 3,
      name: 'Sports',
      description: 'Tailored recovery programs for athletes to regain peak performance post-injury.',
      icon: Icons.sports_tennis,
      color: Color(0xFF4CAF50),
      isActive: true,
    ),
    ServiceModel(
      id: 4,
      name: 'Maternity',
      description: 'Supportive exercises for prenatal and postnatal care to promote maternal health.',
      icon: Icons.pregnant_woman,
      color: Color(0xFFFF9800),
      isActive: true,
    ),
    ServiceModel(
      id: 5,
      name: 'Fitness',
      description: 'Personalized fitness plans to improve strength, flexibility, and overall wellness.',
      icon: Icons.directions_run,
      color: Color(0xFF2196F3),
      isActive: false,
    ),
    ServiceModel(id: 6, name: 'Geriatric', description: 'Gentle therapy for elderly patients to improve mobility and reduce pain.', icon: Icons.elderly, color: Color(0xFF9C27B0), isActive: true),
    ServiceModel(id: 7, name: 'Pediatric', description: 'Therapy for children to support developmental and physical milestones.', icon: Icons.child_care, color: Color(0xFFE91E63), isActive: true),
    ServiceModel(
      id: 8,
      name: 'Pain Management',
      description: 'Advanced techniques to alleviate chronic pain and improve quality of life.',
      icon: Icons.healing,
      color: Color(0xFF009688),
      isActive: false,
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    filterServices();
  }

  void filterServices() {
    filteredServices.assignAll(services);
  }

  void searchServices(String query) {
    if (query.isEmpty) {
      filterServices();
    } else {
      filteredServices.assignAll(services.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList());
    }
  }

  void toggleServiceStatus(int serviceId, bool isActive) {
    int index = services.indexWhere((e) => e.id == serviceId);
    if (index != -1) {
      services[index].isActive = isActive;
    }
    filterServices();
    update();
  }
}
