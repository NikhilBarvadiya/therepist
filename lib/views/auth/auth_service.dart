import 'package:get/get.dart';
import 'package:therepist/models/recharge_model.dart';
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/network/api_index.dart';
import 'package:therepist/utils/network/api_manager.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/utils/storage.dart';
import 'package:therepist/utils/toaster.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async => this;

  Future<void> login(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.login, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      await write(AppSession.token, response.data["accessToken"]);
      await write(AppSession.userData, response.data["doctor"]);
      if (response.data["isEmailVerified"] != true) {
        await sendOTP({'email': request["email"]});
        Get.toNamed(AppRouteNames.otp, arguments: request["email"].toString());
      } else {
        Get.toNamed(AppRouteNames.dashboard);
      }
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> sendOTP(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.otpSend, request, ApiType.post);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to send OTP');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> verifyOTP(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.otpVerify, request, ApiType.post);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to verify OTP');
        return null;
      }
      await write(AppSession.userData, response.data["doctor"]);
      Get.toNamed(AppRouteNames.dashboard);
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> forgotPassword(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.forgotPassword, request, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to send reset link');
        return null;
      }
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<void> register(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.register, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      Get.close(1);
      toaster.success(response.message.toString().capitalizeFirst.toString());
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> getServices({int page = 1, String search = ""}) async {
    try {
      final response = await ApiManager().call("${APIIndex.services}?page=$page&limit=10&search=$search&isActive=true", {}, ApiType.get);
      if (!response.success || response.data == null) return [];
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return [];
    }
  }

  Future<dynamic> getEquipment({int page = 1, String search = ""}) async {
    try {
      final response = await ApiManager().call("${APIIndex.equipment}?page=$page&limit=10&search=$search&isActive=true", {}, ApiType.get);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> doctorServices({int page = 1, String search = ""}) async {
    try {
      final response = await ApiManager().call("${APIIndex.doctorServices}?page=$page&limit=10&search=$search&isActive=true", {}, ApiType.get);
      if (!response.success || response.data == null) return [];
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return [];
    }
  }

  Future<dynamic> toggleService({required String serviceId, required bool isActive}) async {
    try {
      final response = await ApiManager().call(APIIndex.toggleService, {"serviceId": serviceId, "isActive": isActive}, ApiType.post);
      if (!response.success || response.data == null) return [];
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return [];
    }
  }

  Future<dynamic> doctorEquipment({int page = 1, String search = ""}) async {
    try {
      final response = await ApiManager().call("${APIIndex.doctorEquipment}?page=$page&limit=10&search=$search&isActive=true", {}, ApiType.get);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> toggleEquipment({required String equipmentId, required bool isActive}) async {
    try {
      final response = await ApiManager().call(APIIndex.toggleEquipment, {"equipmentId": equipmentId, "isActive": isActive}, ApiType.post);
      if (!response.success || response.data == null) return [];
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return [];
    }
  }

  Future<dynamic> getProfile() async {
    try {
      final response = await ApiManager().call(APIIndex.getProfile, {}, ApiType.get);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> updateProfile(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.updateProfile, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> updatePassword(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.updatePassword, request, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to update password');
        return null;
      }
      return true;
    } catch (err) {
      toaster.error('Network error: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> updateWorkingDays(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.updateWorkingDays, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> getRecognitions({int page = 1, int limit = 10}) async {
    try {
      final response = await ApiManager().call('${APIIndex.recognitions}?page=$page&limit=$limit', {}, ApiType.get);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to load recognitions');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error('Failed to load recognitions: ${err.toString()}');
      return;
    }
  }

  Future<dynamic> getAppointments({required String queryString}) async {
    try {
      final response = await ApiManager().call("${APIIndex.getAppointments}?$queryString&isActive=true", {}, ApiType.get);
      if (!response.success || response.data == null) return [];
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return [];
    }
  }

  Future<dynamic> requestsAccept({required String requestId}) async {
    try {
      final response = await ApiManager().call(APIIndex.requestsAccept, {"requestId": requestId}, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      toaster.success('Appointment accepted successfully');
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> requestsCancel({required String requestId}) async {
    try {
      final response = await ApiManager().call(APIIndex.requestsCancel, {"requestId": requestId}, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      toaster.success('Appointment cancelled successfully');
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> completeAppointment({required String requestId}) async {
    try {
      final response = await ApiManager().call(APIIndex.completeAppointment, {"requestId": requestId}, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      toaster.success('Appointment completed successfully');
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<List<RechargePlan>> getRechargePlans() async {
    try {
      final response = await ApiManager().call(APIIndex.rechargePlans, {}, ApiType.get);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to load recharge plans');
        return [];
      }
      final List<dynamic> plansData = response.data;
      return plansData.map((plan) => RechargePlan.fromJson(plan)).where((plan) => plan.status).toList();
    } catch (err) {
      toaster.error('Failed to load recharge plans: ${err.toString()}');
      return [];
    }
  }

  Future<DoctorRechargePayment> createRechargePayment(CreateRechargeRequest request) async {
    try {
      final response = await ApiManager().call(APIIndex.createRechargePayment, request.toJson(), ApiType.post);
      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to create recharge payment');
      }
      return DoctorRechargePayment.fromJson(response.data);
    } catch (err) {
      toaster.error('Failed to create payment: ${err.toString()}');
      rethrow;
    }
  }

  Future<dynamic> getWalletTransactions({int page = 1, int limit = 10, String? status, String? dateFrom, String? dateTo}) async {
    try {
      final queryParams = {'page': page.toString(), 'limit': limit.toString()};
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }
      if (dateFrom != null) {
        queryParams['dateFrom'] = dateFrom;
      }
      if (dateTo != null) {
        queryParams['dateTo'] = dateTo;
      }
      final queryString = queryParams.entries.map((entry) => '${entry.key}=${entry.value}').join('&');
      final response = await ApiManager().call('${APIIndex.walletTransactions}?$queryString', {}, ApiType.post);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to load transactions');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error('Failed to load transactions: ${err.toString()}');
      return;
    }
  }
}
