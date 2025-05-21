import 'package:flutter_getx_boilerplate/api/ttlock_api_service.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:get/get.dart';
import './passcode_manager_controller.dart';

class PasscodeManagerBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TTLockRepository>(
      () => TTLockRepository(
        apiService: Get.find<TTLockApiService>(),
      ),
    );
    Get.lazyPut<PasscodeManagerController>(
      () => PasscodeManagerController(Get.find()),
    );
  }
}
