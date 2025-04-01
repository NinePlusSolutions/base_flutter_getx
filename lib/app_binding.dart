import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/shared/services/user_service.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/shared/services/app_services.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(ApiServices(), permanent: true);

    // Initialize AppServices and get device token
    Get.put(AppServices(), permanent: true);
    Get.put(UserService(), permanent: true);
  }
}
