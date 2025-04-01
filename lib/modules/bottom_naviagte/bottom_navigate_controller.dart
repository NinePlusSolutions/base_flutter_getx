import 'package:flutter_getx_boilerplate/shared/services/storage_service.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final locale = StorageService.lang.obs;

  BottomNavController();

  @override
  void onInit() {
    super.onInit();
    ever(locale, (_) {
      update();
    });
  }
}
