import 'package:flutter_getx_boilerplate/modules/checkin/checkin_controller.dart';
import 'package:flutter_getx_boilerplate/shared/services/camera_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:get/get.dart';

class CheckinBinding implements Bindings {
  @override
  void dependencies() {
    // Register services
    Get.lazyPut<CameraService>(() => CameraService());
    Get.lazyPut<LocationService>(() => LocationService());

    // Register controller
    Get.lazyPut<CheckinController>(() => CheckinController());
  }
}
