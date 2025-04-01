import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/repositories/home_repository.dart';
import 'package:flutter_getx_boilerplate/repositories/profile_repository.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(
        apiClient: Get.find(),
      ),
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(
        apiClient: Get.find(),
      ),
    );
    Get.put<HomeController>(HomeController(Get.find()),
    );
  }
}
