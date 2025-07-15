import 'package:flutter_getx_boilerplate/modules/issue_report/issue_report_controller.dart';
import 'package:flutter_getx_boilerplate/shared/services/camera_service.dart';
import 'package:flutter_getx_boilerplate/shared/services/location_service.dart';
import 'package:get/get.dart';

class IssueReportBinding implements Bindings {
  @override
  void dependencies() {
    // Register services if not already registered
    if (!Get.isRegistered<CameraService>()) {
      Get.lazyPut<CameraService>(() => CameraService());
    }
    if (!Get.isRegistered<LocationService>()) {
      Get.lazyPut<LocationService>(() => LocationService());
    }

    // Register controller
    Get.lazyPut<IssueReportController>(() => IssueReportController());
  }
}
