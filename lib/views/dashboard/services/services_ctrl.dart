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
      isActive: true,
      rate: 1200.0,
    ),
    ServiceModel(id: 2, name: 'Neuro', description: 'Specialized therapy for neurological conditions to enhance motor skills and coordination.', icon: Icons.psychology, isActive: false, rate: 1500.0),
    ServiceModel(id: 3, name: 'Sports', description: 'Tailored recovery programs for athletes to regain peak performance post-injury.', icon: Icons.sports_tennis, isActive: true, rate: 1800.0),
    ServiceModel(id: 4, name: 'Maternity', description: 'Supportive exercises for prenatal and postnatal care to promote maternal health.', icon: Icons.pregnant_woman, isActive: true, rate: 1000.0),
    ServiceModel(id: 5, name: 'Fitness', description: 'Personalized fitness plans to improve strength, flexibility, and overall wellness.', icon: Icons.directions_run, isActive: false, rate: 800.0),
    ServiceModel(id: 6, name: 'Geriatric', description: 'Gentle therapy for elderly patients to improve mobility and reduce pain.', icon: Icons.elderly, isActive: true, rate: 900.0),
    ServiceModel(id: 7, name: 'Pediatric', description: 'Therapy for children to support developmental and physical milestones.', icon: Icons.child_care, isActive: true, rate: 1100.0),
    ServiceModel(id: 8, name: 'Pain Management', description: 'Advanced techniques to alleviate chronic pain and improve quality of life.', icon: Icons.healing, isActive: false, rate: 1300.0),
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
