import 'package:get/get.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> todayAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> pendingAppointments = <AppointmentModel>[].obs;

  final RxInt todayAppointmentsCount = 0.obs;
  final RxInt pendingRequestsCount = 0.obs;

  final RxBool isLoading = false.obs, isDeleteLoading = false.obs, isAcceptLoading = false.obs;
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
    getUserProfile();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      await Future.wait([loadAppointments()]);
    } catch (e) {
      toaster.error('Error loading home data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAppointments() async {
    try {
      final response = await _authService.getAppointments(page: 1);
      if (response != null && response['docs'] is List) {
        final List appointmentsData = response['docs'];
        todayAppointmentsCount.value = int.tryParse(response['totalDocs'].toString()) ?? 0;
        appointments.assignAll(appointmentsData.map((item) => AppointmentModel.fromJson(item)).toList());
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        todayAppointments.assignAll(
          appointments.where((appointment) {
            final appointmentDate = DateTime(appointment.requestedAt.year, appointment.requestedAt.month, appointment.requestedAt.day);
            return appointmentDate.isAtSameMomentAs(today);
          }).toList(),
        );
      }
      final pendingResponse = await _authService.getAppointments(status: 'pending', page: 1);
      if (pendingResponse != null && pendingResponse['docs'] is List) {
        final List appointmentsData = pendingResponse['docs'];
        pendingRequestsCount.value = int.tryParse(pendingResponse['totalDocs'].toString()) ?? 0;
        pendingAppointments.assignAll(appointmentsData.map((item) => AppointmentModel.fromJson(item)).toList());
      }
    } catch (e) {
      toaster.error('Error loading appointments: ${e.toString()}');
    }
  }

  Future<void> getUserProfile() async {
    try {
      final response = await _authService.getProfile();
      if (response != null && response['name'] != null) {
        userName.value = response['name'];
      }
    } catch (e) {
      userName.value = 'Doctor';
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      isAcceptLoading.value = true;
      final response = await _authService.requestsAccept(appointmentId: requestId);
      if (response != null) {
        pendingAppointments.removeWhere((request) => request.id == requestId);
        pendingRequestsCount.value -= 1;
        toaster.success('Request accepted successfully');
        await loadAppointments();
      }
    } catch (e) {
      toaster.error('Error accepting request: ${e.toString()}');
    } finally {
      isAcceptLoading.value = false;
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      isDeleteLoading.value = true;
      final response = await _authService.requestsCancel(appointmentId: requestId);
      if (response != null) {
        pendingAppointments.removeWhere((request) => request.id == requestId);
        pendingRequestsCount.value -= 1;
        toaster.success('Request declined successfully');
      }
    } catch (e) {
      toaster.error('Error declining request: ${e.toString()}');
    } finally {
      isDeleteLoading.value = false;
    }
  }
}
