import 'package:get/get.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';
import 'package:therepist/views/dashboard/home/ui/appointment_countdown_popup.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> todayAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> pendingAppointments = <AppointmentModel>[].obs;

  final RxInt todayAppointmentsCount = 0.obs;
  final RxInt pendingRequestsCount = 0.obs;

  final RxBool isLoading = false.obs, isAcceptLoading = false.obs;
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
      await Future.wait([loadTodayAppointments(), loadPendingAppointments()]);
    } catch (e) {
      toaster.error('Error loading home data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingAppointments() async {
    try {
      final params = <String, String>{'page': "1", 'limit': '5'};
      params['status'] = "Pending";
      final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final pendingResponse = await _authService.getAppointments(queryString: queryString);
      if (pendingResponse != null && pendingResponse['docs'] is List) {
        List appointmentsData = pendingResponse['docs'];
        appointmentsData = appointmentsData.where((appointment) => appointment["status"].toLowerCase() == "pending").toList();
        pendingAppointments.assignAll(appointmentsData.map((item) => AppointmentModel.fromJson(item)).toList());
        pendingRequestsCount.value = int.tryParse(pendingResponse['totalDocs'].toString()) ?? 0;
      }
    } catch (e) {
      toaster.error('Error loading appointments: ${e.toString()}');
    }
  }

  Future loadTodayAppointments() async {
    final now = DateTime.now();
    final params = <String, String>{'page': "1", 'limit': '5'};
    final today = DateTime(now.year, now.month, now.day);
    params['dateFrom'] = today.toIso8601String();
    params['dateTo'] = now.toIso8601String();
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final response = await _authService.getAppointments(queryString: queryString);
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
      final response = await _authService.requestsAccept(requestId: requestId);
      if (response != null) {
        pendingAppointments.removeWhere((request) => request.id == requestId);
        pendingRequestsCount.value -= 1;
        toaster.success('Request accepted successfully');
        await loadHomeData();
      }
    } catch (e) {
      toaster.error('Error accepting request: ${e.toString()}');
    } finally {
      isAcceptLoading.value = false;
    }
  }

  bool _isOrderPopupOpen = false;
  String? _currentOrderId;

  Future<void> showAppointmentCountdownPopup(AppointmentModel appointment) async {
    try {
      final requestId = appointment.id.toString();
      if (_isOrderPopupOpen && _currentOrderId == requestId) {
        return;
      }
      if (_isOrderPopupOpen) {
        Get.close(1);
      }
      _isOrderPopupOpen = true;
      _currentOrderId = requestId;
      await Get.dialog(
        AppointmentCountdownPopup(appointment: appointment, onAccept: () => acceptRequest(requestId.toString()), onReject: () => Get.close(1), onTimeout: () => _resetPopupState()),
        barrierDismissible: false,
      );
      _isOrderPopupOpen = false;
      _currentOrderId = null;
    } catch (e) {
      toaster.error('Error showing appointments popup: $e');
      _isOrderPopupOpen = false;
      _currentOrderId = null;
    }
  }

  void _resetPopupState() {
    _isOrderPopupOpen = false;
    _currentOrderId = null;
  }
}
