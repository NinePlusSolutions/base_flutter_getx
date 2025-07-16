import 'package:flutter_getx_boilerplate/modules/checkin/checkin_controller.dart';
import 'package:flutter_getx_boilerplate/shared/services/camera_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_tracking_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/connectivity_service.dart';
import 'package:get/get.dart';

class CheckinBinding implements Bindings {
  @override
  void dependencies() {
    // Register core services
    Get.lazyPut<CameraService>(() => CameraService());
    Get.lazyPut<LocationService>(() => LocationService());

    // Register enhanced tracking services
    Get.lazyPut<ConnectivityService>(() => ConnectivityService());
    Get.lazyPut<LocationTrackingService>(() => LocationTrackingService());

    // Register controller
    Get.lazyPut<CheckinController>(() => CheckinController());
  }
}
