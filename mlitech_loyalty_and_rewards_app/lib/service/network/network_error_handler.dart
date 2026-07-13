import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:loyalty_customer/routes/app_routes.dart';

class NetworkErrorHandler {
  NetworkErrorHandler._();
  static final NetworkErrorHandler instance = NetworkErrorHandler._();

  bool _isNavigating = false;

  static bool isNetworkError(Object error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout;
    }
    return false;
  }

  static void handleIfNetworkError(Object error) {
    if (isNetworkError(error)) {
      instance.goToOfflineScreen();
    }
  }

  bool get isOnOfflineScreen =>
      Get.currentRoute == AppRoutes.instance.noInternetScreen;

  bool _shouldSkipRedirect() {
    final route = Get.currentRoute;
    return route == AppRoutes.instance.noInternetScreen ||
        route == AppRoutes.instance.initial;
  }

  void goToOfflineScreen() {
    if (_isNavigating || _shouldSkipRedirect()) return;

    _isNavigating = true;
    Get.offAllNamed(AppRoutes.instance.noInternetScreen);
    _isNavigating = false;
  }
}
