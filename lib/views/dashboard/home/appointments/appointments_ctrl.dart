import 'package:get/get.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';

class AppointmentsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> filteredAppointments = <AppointmentModel>[].obs;
  final RxString selectedStatus = ''.obs, searchQuery = ''.obs;
  final RxBool isLoading = false.obs, hasMore = true.obs;
  final RxBool isDeleteLoading = false.obs, isAcceptLoading = false.obs, isCompleteLoading = false.obs;
  final RxInt currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments({bool loadMore = false}) async {
    if (isLoading.value) return;
    if (!loadMore) {
      currentPage.value = 1;
      hasMore.value = true;
      appointments.clear();
    }
    isLoading.value = true;
    try {
      final response = await _authService.getAppointments(page: currentPage.value, status: selectedStatus.value, search: searchQuery.value);
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => AppointmentModel.fromJson(item)).toList();
          if (loadMore) {
            appointments.addAll(parsedServices);
          } else {
            appointments.assignAll(parsedServices);
          }
          filteredAppointments.assignAll(appointments);
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
          toaster.warning(response.message ?? 'Failed to load appointments');
        }
        hasMore.value = false;
      }
    } catch (err) {
      toaster.error('Error loading appointments: ${err.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void searchAppointments(String query) {
    if (query.isEmpty) {
      filteredAppointments.value = List.from(appointments);
    } else {
      filteredAppointments.value = appointments
          .where((appointment) => appointment.patientName.toLowerCase() == query.toLowerCase() || appointment.serviceName.toLowerCase() == query.toLowerCase())
          .toList();
    }
  }

  void filterAppointmentsByStatus(String status) {
    if (status.toLowerCase() == "all") {
      selectedStatus.value = "";
      filteredAppointments.value = List.from(appointments);
      update();
      return;
    }
    selectedStatus.value = status;
    if (status.isEmpty) {
      filteredAppointments.value = List.from(appointments);
    } else {
      filteredAppointments.value = appointments.where((appointment) => appointment.status.toLowerCase() == status.toLowerCase()).toList();
    }
    update();
  }

  Future<void> acceptAppointment(String requestId) async {
    try {
      isAcceptLoading.value = true;
      final response = await _authService.requestsAccept(requestId: requestId);
      if (response != null) {
        _updateAppointmentStatus(requestId, 'accepted');
      }
    } catch (err) {
      toaster.error('Error accepting appointment: ${err.toString()}');
    } finally {
      isAcceptLoading.value = false;
    }
  }

  Future<void> cancelAppointment(String requestId) async {
    try {
      isDeleteLoading.value = true;
      final response = await _authService.requestsCancel(requestId: requestId);
      if (response != null) {
        _updateAppointmentStatus(requestId, 'cancelled');
      }
    } catch (err) {
      toaster.error('Error accepting appointment: ${err.toString()}');
    } finally {
      isDeleteLoading.value = false;
    }
  }

  Future<void> completeAppointment(String requestId) async {
    try {
      isCompleteLoading.value = true;
      final response = await _authService.completeAppointment(requestId: requestId);
      if (response != null) {
        _updateAppointmentStatus(requestId, 'completed');
      }
    } catch (err) {
      toaster.error('Error accepting appointment: ${err.toString()}');
    } finally {
      isCompleteLoading.value = false;
    }
  }

  void _updateAppointmentStatus(String appointmentId, String status) {
    final index = appointments.indexWhere((app) => app.id == appointmentId);
    if (index != -1) {
      appointments[index] = appointments[index].copyWith(status: status);
      filterAppointmentsByStatus(selectedStatus.value);
    }
  }

  void loadMoreAppointments() {
    if (hasMore.value && !isLoading.value) {
      currentPage.value++;
      loadAppointments(loadMore: true);
    }
  }

  Future<void> refreshAppointments() async {
    currentPage.value = 1;
    await loadAppointments();
  }
}
