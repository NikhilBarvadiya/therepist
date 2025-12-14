import 'package:get/get.dart';
import 'package:therepist/views/dashboard/equipment/equipment_ctrl.dart';
import 'package:therepist/views/dashboard/services/services_ctrl.dart';

class DashboardCtrl extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    if (index == 1) {
      if (Get.isRegistered<ServicesCtrl>()) {
        Get.find<ServicesCtrl>().clearSearch();
      }
    } else if (index == 2) {
      if (Get.isRegistered<EquipmentCtrl>()) {
        Get.find<EquipmentCtrl>().clearSearch();
      }
    }
    currentIndex.value = index;
  }
}
