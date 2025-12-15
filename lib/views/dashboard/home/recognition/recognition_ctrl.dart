import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:therepist/models/recognition_model.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/auth/auth_service.dart';

class RecognitionCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxList<Recognition> recognitions = <Recognition>[].obs;
  final RxBool _isLoading = false.obs, _isLoadingMore = false.obs, _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;

  bool get isLoading => _isLoading.value;

  bool get isLoadingMore => _isLoadingMore.value;

  bool get hasMore => _hasMore.value;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () async => await loadRecognitions());
  }

  Future<void> loadRecognitions({bool reset = false}) async {
    if (reset) {
      _currentPage.value = 1;
      _hasMore.value = true;
      _isLoading.value = true;
    } else if (!_hasMore.value) {
      return;
    } else {
      _isLoadingMore.value = true;
    }
    try {
      final response = await _authService.getRecognitions(page: _currentPage.value, limit: 10);
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => Recognition.fromJson(item)).toList();
          if (_isLoadingMore.value) {
            recognitions.addAll(parsedServices);
          } else {
            recognitions.assignAll(parsedServices);
          }
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['currentPage'] ?? _currentPage.value;
          _hasMore.value = currentPageNum < totalPages;
          if (_hasMore.value) {
            _currentPage.value = currentPageNum + 1;
          }
        } else {
          _hasMore.value = false;
        }
      } else {
        if (!_isLoadingMore.value) {
          toaster.warning(response.message ?? 'Failed to load recognition');
        }
        _hasMore.value = false;
      }
    } catch (e) {
      toaster.error('Failed to load recognitions: $e');
    } finally {
      if (reset) {
        _isLoading.value = false;
      }
      _isLoadingMore.value = false;
    }
  }

  Future<void> refreshRecognitions() async {
    await loadRecognitions(reset: true);
  }

  Color getStatusColor(Recognition recognition) {
    return recognition.statusColor;
  }

  String getStatusText(Recognition recognition) {
    return recognition.statusText;
  }

  String formatDurationDays(int days) {
    return '$days days';
  }
}
