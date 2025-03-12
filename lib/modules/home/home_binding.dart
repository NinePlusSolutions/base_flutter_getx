import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/repositories/auth_repository.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        apiClient: Get.find(),
      ),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find()),
    );
  }
}
