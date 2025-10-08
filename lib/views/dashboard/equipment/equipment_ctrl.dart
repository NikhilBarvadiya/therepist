import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/views/auth/auth_service.dart';
import '../../../models/service_model.dart';

class EquipmentCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var equipment = <ServiceModel>[].obs, filteredEquipment = <ServiceModel>[].obs;
  var isLoading = false.obs, isLoadMoreLoading = false.obs, hasMore = true.obs;
  var currentPage = 1.obs;
  var searchQuery = ''.obs, errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices({bool loadMore = false}) async {
    if (isLoading.value) return;
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMore.value = true;
        equipment.clear();
        filteredEquipment.clear();
        errorMessage.value = '';
      } else {
        if (!hasMore.value || isLoadMoreLoading.value) return;
        isLoadMoreLoading.value = true;
      }
      final response = await _authService.doctorEquipment(page: currentPage.value, search: searchQuery.value);
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => ServiceModel.fromJson(item)).toList();
          if (loadMore) {
            equipment.addAll(parsedServices);
          } else {
            equipment.assignAll(parsedServices);
          }
          filteredEquipment.assignAll(equipment);
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['currentPage'] ?? currentPage.value;
          hasMore.value = currentPageNum < totalPages;
          if (hasMore.value) {
            currentPage.value = currentPageNum + 1;
          }
        } else {
          hasMore.value = false;
        }
      } else {
        if (!loadMore) {
          errorMessage.value = 'No services found';
        }
        hasMore.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load services: ${e.toString()}';
      if (!loadMore) {
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 3));
      }
    } finally {
      isLoading.value = false;
      isLoadMoreLoading.value = false;
      update();
    }
  }

  void searchServices(String query) {
    searchQuery.value = query.trim();
    debounce<String>(searchQuery, (_) => loadServices(), time: const Duration(milliseconds: 500));
  }

  Future<void> toggleServiceStatus(String equipmentId, bool isActive) async {
    var response = await _authService.toggleEquipment(equipmentId: equipmentId, isActive: isActive);
    if (response != null) {
      final index = equipment.indexWhere((s) => s.id == equipmentId);
      if (index != -1) {
        equipment[index].isActive = isActive;
        filteredEquipment.assignAll(equipment);
        update();
      }
    }
  }

  void loadMoreServices() {
    if (hasMore.value && !isLoading.value && !isLoadMoreLoading.value) {
      loadServices(loadMore: true);
    }
  }

  Future<void> refreshServices() async => await loadServices();

  void clearSearch() {
    searchQuery.value = '';
    loadServices();
  }
}
