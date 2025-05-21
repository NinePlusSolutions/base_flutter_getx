import 'package:flutter_getx_boilerplate/api/ttlock_api_service.dart';
import 'package:flutter_getx_boilerplate/repositories/ttlock_repository.dart';
import 'package:get/get.dart';
import './create_passcode_controller.dart';

class CreatePasscodeBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TTLockRepository>(
      () => TTLockRepository(
        apiService: Get.find<TTLockApiService>(),
      ),
    );
    Get.lazyPut<CreatePasscodeController>(
      () => CreatePasscodeController(Get.find()),
    );
  }
}
