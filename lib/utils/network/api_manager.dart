import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:therepist/utils/config/session.dart';
import 'package:therepist/utils/internet_checker.dart';
import 'package:therepist/utils/network/api_config.dart';
import 'package:therepist/utils/network/api_response.dart';
import 'package:therepist/utils/routes/route_name.dart';
import 'package:therepist/utils/storage.dart';
import 'package:therepist/utils/toaster.dart';
import 'package:therepist/views/splash/splash_ctrl.dart';

Dio dio = Dio();

enum ApiType { get, post, put, delete }

class ApiManager {
  ApiManager() {
    dio.options
      ..baseUrl = APIConfig.apiBaseURL
      ..connectTimeout = const Duration(milliseconds: 20000)
      ..receiveTimeout = const Duration(milliseconds: 20000)
      ..validateStatus = (int? status) {
        return status! > 0;
      }
      ..headers = {'Accept': 'application/json', 'content-type': 'application/json'};
  }

  Future<APIResponse> call(String apiName, body, type) async {
    bool isInternet = await internetChecker.isNetworkConnection();
    if (isInternet) {
      try {
        String token = await read(AppSession.token) ?? "";
        if (token.isNotEmpty) {
          dio.options.headers["Authorization"] = "Bearer $token";
          dio.options.headers["token"] = token;
        }
        if (kDebugMode) {
          print("Api Name :${APIConfig.apiBaseURL}$apiName");
          print("AuthToken :${dio.options.headers["Authorization"]}");
          print("Request :$body");
        }
        Response? response;
        switch (type) {
          case ApiType.post:
            response = await dio.post(apiName, data: body);
            break;
          case ApiType.delete:
            response = await dio.delete(apiName, data: body);
            break;
          case ApiType.put:
            response = await dio.put(apiName, data: body);
            break;
          case ApiType.get:
            response = await dio.get(apiName, data: body);
            break;
        }
        log("Response...${response!.data}");
        return _formatOutput(response, null);
      } on DioException catch (err) {
        if (err.type == DioExceptionType.badResponse) {
          if (err.response?.statusCode == 401) {
            _errorThrow(err);
            await clearStorage();
            Get.offNamedUntil(AppRouteNames.splash, (Route<dynamic> route) => false);
            Get.put(SplashCtrl(), permanent: true).onReady();
            return toaster.error("Something went wrong server error ${err.response?.statusCode}!");
          } else {
            _errorThrow(err);
            return toaster.error("Something went wrong server error ${err.response?.statusCode}!");
          }
        } else if (err.type == DioExceptionType.receiveTimeout || err.type == DioExceptionType.connectionTimeout) {
          _errorThrow(err);
          return toaster.error("Request timeout 408");
        } else {
          _errorThrow(err);
          return toaster.error("Something went wrong server error ${err.response?.statusCode}!");
        }
      } catch (err) {
        return _formatOutput(null, err.toString());
      }
    } else {
      internetChecker.goToNoInternetScreen();
      return _formatOutput(null, "Please make sure the internet is connected!");
    }
  }

  APIResponse _formatOutput(Response? response, String? message) {
    if (response == null) {
      return APIResponse.fromJson({"message": message, "data": 0, "status": 500});
    } else {
      return APIResponse.fromJson(response.data);
    }
  }

  _errorThrow(DioException err) async {
    if (err.response != null) {
      dynamic userData = await read(AppSession.userData);
      var errorShow = {"Api": err.response!.realUri, "Status": err.response!.statusCode, "UserName": userData["name"] ?? "", "StatusMessage": err.response!.statusMessage};
      throw Exception(errorShow);
    }
  }
}
