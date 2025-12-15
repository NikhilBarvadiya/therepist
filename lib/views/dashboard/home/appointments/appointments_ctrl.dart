import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/models/appointment_model.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';
import 'package:therepist/views/dashboard/home/appointments/ui/date_filter.dart';

class AppointmentsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxString selectedStatus = 'all'.obs, searchQuery = ''.obs, selectedDateRange = 'All Time'.obs;
  final RxBool isLoading = false.obs, hasMore = true.obs;
  final RxBool isDeleteLoading = false.obs, isAcceptLoading = false.obs, isCompleteLoading = false.obs;
  final dateRanges = ['All Time', 'Today', 'Yesterday', 'Last 7 Days', 'Last 30 Days', 'This Month', 'Last Month', 'Custom Range'];
  var customStartDate = Rx<DateTime?>(null), customEndDate = Rx<DateTime?>(null);
  var currentPage = 1.obs, totalDocs = 0.obs;
  final RxSet<String> expandedCards = <String>{}.obs;


  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Map<String, String> _getDateParameters() {
    final now = DateTime.now();
    final Map<String, String> params = {};
    switch (selectedDateRange.value) {
      case 'Today':
        final today = DateTime(now.year, now.month, now.day);
        params['dateFrom'] = today.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'Yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = end.toIso8601String();
        break;
      case 'Last 7 Days':
        final start = now.subtract(const Duration(days: 7));
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'Last 30 Days':
        final start = now.subtract(const Duration(days: 30));
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'This Month':
        final start = DateTime(now.year, now.month, 1);
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59);
        params['dateFrom'] = lastMonth.toIso8601String();
        params['dateTo'] = end.toIso8601String();
        break;
      case 'Custom Range':
        if (customStartDate.value != null) {
          params['dateFrom'] = customStartDate.value!.toIso8601String();
        }
        if (customEndDate.value != null) {
          params['dateTo'] = customEndDate.value!.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toIso8601String();
        }
        break;
      default:
        break;
    }
    return params;
  }

  void showDateFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(DateFilter(), isScrollControlled: true, enableDrag: true, backgroundColor: Colors.transparent);
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
      final params = <String, String>{'page': currentPage.value.toString(), 'limit': '10'};
      if (selectedStatus.value.isNotEmpty && selectedStatus.value.toLowerCase() != 'all') {
        params['status'] = selectedStatus.value;
      }
      if (searchQuery.value != '') {
        params['search'] = searchQuery.value.toLowerCase();
      }
      final dateParams = _getDateParameters();
      params.addAll(dateParams);
      final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final response = await _authService.getAppointments(queryString: queryString);
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => AppointmentModel.fromJson(item)).toList();
          if (loadMore) {
            appointments.addAll(parsedServices);
          } else {
            appointments.assignAll(parsedServices);
          }
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['currentPage'] ?? currentPage.value;
          totalDocs.value = response['totalDocs'] ?? 0;
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
    searchQuery.value = query.trim();
    debounce<String>(searchQuery, (_) => loadAppointments(), time: const Duration(milliseconds: 500));
  }

  void filterAppointmentsByStatus(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    update();
    loadAppointments();
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

  void clearExpandedCards() {
    expandedCards.clear();
  }
}
