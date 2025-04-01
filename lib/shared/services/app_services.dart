import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class AppServices extends GetxService {
  static AppServices get to => Get.find<AppServices>();

  final Rx<String> _deviceId = ''.obs;

  String get deviceToken => _deviceId.value;

  @override
  Future<void> onInit() async {
    await initializeDeviceToken();
    super.onInit();
  }

  Future<void> initializeDeviceToken() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      _deviceId.value = await _getDeviceId(deviceInfo);

      if (kDebugMode) {
        print('Device ID: ${_deviceId.value}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device ID: $e');
      }
      _deviceId.value = 'error-getting-device-id';
    }
  }

  Future<String> _getDeviceId(DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }

    return 'unknown-device';
  }
}
