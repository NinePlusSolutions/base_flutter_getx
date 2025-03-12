import 'package:flutter_getx_boilerplate/modules/auth/auth_controller.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:get/get.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        apiClient: Get.find(),
      ),
    );

    Get.lazyPut<AuthController>(
      () => AuthController(Get.find()),
    );
  }
}
