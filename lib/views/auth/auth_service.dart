import 'package:get/get.dart';
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
      Get.toNamed(AppRouteNames.dashboard);
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<void> register(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.register, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      Get.back();
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
}
