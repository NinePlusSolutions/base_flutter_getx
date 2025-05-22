import 'package:flutter_getx_boilerplate/repositories/repositories.dart';
import 'package:get/get.dart';
import '../../api/ttlock_api_service.dart';
import '../../repositories/ttlock_repository.dart';
import 'lock_detail_controller.dart';

class LockDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LockRepository>(
      () => LockRepository(
        apiClient: Get.find(),
      ),
    );

    Get.lazyPut<EkeyRepository>(
      () => EkeyRepository(
        apiClient: Get.find(),
      ),
    );

    Get.lazyPut<GatewayRepository>(
      () => GatewayRepository(
        apiClient: Get.find(),
      ),
    );

    Get.lazyPut<PasscodeRepository>(
      () => PasscodeRepository(
        apiClient: Get.find(),
      ),
    );

    final TTLockApiService apiService = Get.find<TTLockApiService>();

    Get.lazyPut<TTLockRepository>(() => TTLockRepository(apiService: apiService));
    Get.lazyPut<LockDetailController>(
      () => LockDetailController(
        Get.find(),
      ),
    );
  }
}
