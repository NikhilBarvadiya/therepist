import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/models/models.dart';
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/storage.dart';

class EquipmentCtrl extends GetxController {
  var filteredEquipment = <EquipmentModel>[].obs;

  var equipment = <EquipmentModel>[
    EquipmentModel(id: 1, name: 'Cupping', description: 'Suction-based therapy to promote blood flow and relieve muscle tension.', icon: Icons.spa, isActive: true, rate: 1200.0),
    EquipmentModel(id: 2, name: 'Tapping', description: 'Percussive therapy to stimulate muscles and improve circulation.', icon: Icons.touch_app, isActive: true, rate: 800.0),
    EquipmentModel(id: 3, name: 'Needling', description: 'Dry needling to target trigger points and alleviate pain.', icon: Icons.medical_services, isActive: true, rate: 1500.0),
    EquipmentModel(id: 4, name: 'Laser', description: 'Low-level laser therapy for pain relief and tissue repair.', icon: Icons.light, isActive: true, rate: 2000.0),
    EquipmentModel(id: 5, name: 'Tens', description: 'Transcutaneous electrical nerve stimulation for pain management.', icon: Icons.electrical_services, isActive: true, rate: 1000.0),
    EquipmentModel(id: 6, name: 'Ift', description: 'Interferential therapy for deep tissue pain relief and muscle stimulation.', icon: Icons.vibration, isActive: true, rate: 900.0),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    filterEquipment();
  }

  Future<void> filterEquipment() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      List equipments = userData["equipment"] ?? [];
      if (equipments.isNotEmpty) {
        for (var ele in equipment) {
          ele.isActive = equipments.contains(ele.name);
        }
      }
    }
    filteredEquipment.assignAll(equipment);
  }

  void searchEquipment(String query) {
    if (query.isEmpty) {
      filterEquipment();
    } else {
      filteredEquipment.assignAll(equipment.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList());
    }
  }

  Future<void> toggleEquipmentStatus(int equipmentId, bool isActive) async {
    int index = equipment.indexWhere((e) => e.id == equipmentId);
    if (index != -1) {
      equipment[index] = equipment[index].copyWith(isActive: isActive);
      final userData = await read(AppSession.userData);
      if (userData != null) {
        userData['equipment'] = getSelectedEquipment().map((e) => e.name).toList();
        await write(AppSession.userData, userData);
      }
    }
    filterEquipment();
    update();
  }

  List<EquipmentModel> getSelectedEquipment() {
    return equipment.where((e) => e.isActive == true).toList();
  }
}
