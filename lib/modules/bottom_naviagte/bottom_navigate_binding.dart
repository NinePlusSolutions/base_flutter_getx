import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/modules/home/home_controller.dart';
import 'package:flutter_getx_boilerplate/modules/leave/leave_controller.dart';
import 'package:flutter_getx_boilerplate/modules/profile/controller/profile_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:flutter_getx_boilerplate/repositories/leave_repository.dart';
import 'package:get/get.dart';

import 'bottom_navigate_controller.dart';

class BottomNavigateBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavController>(
          () => BottomNavController(),
    );
    Get.lazyPut<AuthRepository>(
          () => AuthRepository(
        apiClient: Get.find(),
      ),
    );
    Get.lazyPut<LeaveRepository>(
          () => LeaveRepository(
        apiClient: Get.find(),
      ),
    );
    Get.lazyPut<ProfileController>(
          () => ProfileController(Get.find()),
    );
    Get.lazyPut<LeaveController>(
          () => LeaveController(Get.find()),
    );
    HomeBinding().dependencies();
  }
}
