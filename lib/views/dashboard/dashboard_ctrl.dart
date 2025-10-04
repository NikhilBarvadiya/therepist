import 'package:get/get.dart';
import 'package:therepist/models/models.dart';
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/storage.dart';

class DashboardCtrl extends GetxController {
  var currentIndex = 0.obs;

  var appointmentsList = <AppointmentModel>[
    AppointmentModel(id: 1, patientName: 'Alice Johnson', date: '2025-10-03', time: '09:00 AM', service: 'Ortho', status: 'confirmed'),
    AppointmentModel(id: 2, patientName: 'Bob Smith', date: '2025-10-03', time: '10:30 AM', service: 'Neuro', status: 'pending'),
    AppointmentModel(id: 3, patientName: 'Charlie Davis', date: '2025-10-04', time: '11:45 AM', service: 'Sports', status: 'confirmed'),
    AppointmentModel(id: 4, patientName: 'Dana Evans', date: '2025-10-04', time: '02:00 PM', service: 'Maternity', status: 'cancelled'),
    AppointmentModel(id: 5, patientName: 'Eve Franklin', date: '2025-10-05', time: '03:15 PM', service: 'Fitness', status: 'confirmed'),
    AppointmentModel(id: 6, patientName: 'Frank Green', date: '2025-10-05', time: '04:30 PM', service: 'Geriatric', status: 'pending'),
    AppointmentModel(id: 7, patientName: 'Grace Harris', date: '2025-10-06', time: '05:45 PM', service: 'Pediatric', status: 'completed'),
    AppointmentModel(id: 8, patientName: 'Henry Irving', date: '2025-10-06', time: '07:00 PM', service: 'Pain Management', status: 'confirmed'),
    AppointmentModel(id: 9, patientName: 'Isabella James', date: '2025-10-07', time: '08:30 AM', service: 'Ortho', status: 'pending'),
    AppointmentModel(id: 10, patientName: 'Jack King', date: '2025-10-07', time: '01:00 PM', service: 'Sports', status: 'completed'),
  ].obs;

  var filteredAppointments = <AppointmentModel>[].obs;

  var pendingRequestsList = <RequestModel>[
    RequestModel(id: 1, patientName: 'Ivy Jackson', service: 'Ortho', date: '2025-10-07'),
    RequestModel(id: 2, patientName: 'Jack King', service: 'Neuro', date: '2025-10-07'),
    RequestModel(id: 3, patientName: 'Karen Lee', service: 'Sports', date: '2025-10-08'),
    RequestModel(id: 4, patientName: 'Liam Miller', service: 'Maternity', date: '2025-10-08'),
    RequestModel(id: 5, patientName: 'Mia Nelson', service: 'Geriatric', date: '2025-10-09'),
  ].obs;

  var filteredPendingRequests = <RequestModel>[].obs;

  var userName = ''.obs;
  var selectedStatus = ''.obs;
  var selectedService = ''.obs;
  var selectedDate = ''.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filteredAppointments.assignAll(appointmentsList);
    filteredPendingRequests.assignAll(pendingRequestsList);
    loadUserData();
  }

  void loadUserData() async {
    try {
      final userData = await read(AppSession.userData);
      if (userData != null) {
        userName.value = userData['name'] ?? userData['clinic'] ?? "Dr. John Smith";
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void searchAppointments(String query) {
    searchQuery.value = query;
    _applyAppointmentFilters();
  }

  void filterAppointmentsByStatus(String status) {
    if (status == "all") {
      clearAppointmentFilters();
      return;
    }
    selectedStatus.value = status;
    _applyAppointmentFilters();
  }

  void filterAppointmentsByService(String service) {
    selectedService.value = service;
    _applyAppointmentFilters();
  }

  void filterAppointmentsByDate(String date) {
    selectedDate.value = date;
    _applyAppointmentFilters();
  }

  void clearAppointmentFilters() {
    selectedStatus.value = '';
    selectedService.value = '';
    selectedDate.value = '';
    searchQuery.value = '';
    _applyAppointmentFilters();
  }

  void _applyAppointmentFilters() {
    List<AppointmentModel> filtered = appointmentsList;
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where(
            (appointment) =>
                appointment.patientName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                appointment.service.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                appointment.date.contains(searchQuery.value) ||
                appointment.time.toLowerCase().contains(searchQuery.value.toLowerCase()),
          )
          .toList();
    }

    if (selectedStatus.value.isNotEmpty) {
      filtered = filtered.where((appointment) => appointment.status.toLowerCase() == selectedStatus.value.toLowerCase()).toList();
    }

    if (selectedService.value.isNotEmpty) {
      filtered = filtered.where((appointment) => appointment.service.toLowerCase() == selectedService.value.toLowerCase()).toList();
    }

    if (selectedDate.value.isNotEmpty) {
      filtered = filtered.where((appointment) => appointment.date == selectedDate.value).toList();
    }

    filteredAppointments.assignAll(filtered);
  }
}
