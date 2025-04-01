import 'package:flutter_getx_boilerplate/routes/routes.dart';
import 'package:flutter_getx_boilerplate/shared/services/services.dart';
import 'package:get/get.dart';

class NavigatorHelper {
  static toOnBoardScreen() {
    return Get.offNamed(Routes.splash + Routes.onboard);
  }

  static toAuth() {
    StorageService.clear();
    return Get.offNamed(Routes.auth);
  }

  static toRegister() {}

  static toHome() {
    return Get.toNamed(Routes.home);
  }

  static toBottomNav() {
    return Get.offNamed(Routes.navigator);
  }

  static toProfileDetail() {
    return Get.toNamed(Routes.profile);
  }

  static toNotification() {
    return Get.toNamed(Routes.notification);
  }
}
